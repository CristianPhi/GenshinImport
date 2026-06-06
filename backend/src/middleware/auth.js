const pool = require('../config/db');

async function verifyBearerToken(req, res, next) {
  const authHeader = req.headers.authorization || '';

  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Bearer token is required.' });
  }

  const token = authHeader.replace('Bearer ', '').trim();

  try {
    const [rows] = await pool.query(
      'SELECT user_id, token, expired_at FROM auth_tokens WHERE token = ? LIMIT 1',
      [token]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Invalid token.' });
    }

    const tokenRow = rows[0];
    const now = new Date();

    if (tokenRow.expired_at && new Date(tokenRow.expired_at) < now) {
      return res.status(401).json({ message: 'Token expired.' });
    }

    // Get user role
    const [userRows] = await pool.query(
      'SELECT id, role FROM users WHERE id = ? LIMIT 1',
      [tokenRow.user_id]
    );

    if (userRows.length === 0) {
      return res.status(401).json({ message: 'User not found.' });
    }

    req.user = { id: tokenRow.user_id, role: userRows[0].role };
    next();
  } catch (error) {
    res.status(500).json({ message: 'Failed to verify token.', error: error.message });
  }
}

async function verifyAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required.' });
  }
  next();
}

module.exports = { verifyBearerToken, verifyAdmin };
