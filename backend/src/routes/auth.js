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

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ? LIMIT 1', [email]);

    if (rows.length === 0 || rows[0].password !== password) {
      return res.status(401).json({ message: 'Email or password is incorrect.' });
    }

    const user = rows[0];
    const token = generateToken();
    await storeToken(user.id, token);

    return res.json({
      message: 'Login success.',
      token,
      user: {
        id: user.id,
        name: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: 'Login failed.', error: error.message });
  }
});

module.exports = router;
