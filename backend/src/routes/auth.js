const express = require('express');
const crypto = require('crypto');
const pool = require('../config/db');

const router = express.Router();

function generateToken() {
  return crypto.randomBytes(20).toString('hex');
}

async function storeToken(userId, token) {
  const expiredAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
  await pool.query(
    'INSERT INTO auth_tokens (user_id, token, expired_at) VALUES (?, ?, ?)',
    [userId, token, expiredAt]
  );
}

function userResponse(user, token, message) {
  return {
    message,
    token,
    user: {
      id: user.id,
      name: user.username,
      email: user.email,
      role: user.role,
    },
  };
}

router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Username, email, and password are required.' });
  }

  if (password.length > 30) {
    return res.status(400).json({ message: 'Password max 30 characters.' });
  }

  try {
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ? LIMIT 1', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ message: 'Email already registered.' });
    }

    const [result] = await pool.query(
      'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, password, 'user']
    );

    const user = {
      id: result.insertId,
      username,
      email,
      role: 'user',
    };

    const token = generateToken();
    await storeToken(user.id, token);

    return res.status(201).json(userResponse(user, token, 'Register success.'));
  } catch (error) {
    return res.status(500).json({ message: 'Register failed.', error: error.message });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE email = ? OR username = ? LIMIT 1',
      [email, email]
    );

    if (rows.length === 0 || rows[0].password !== password) {
      return res.status(401).json({ message: 'Email or password is incorrect.' });
    }

    const user = rows[0];
    const token = generateToken();
    await storeToken(user.id, token);

    return res.json(userResponse(user, token, 'Login success.'));
  } catch (error) {
    return res.status(500).json({ message: 'Login failed.', error: error.message });
  }
});

module.exports = router;
