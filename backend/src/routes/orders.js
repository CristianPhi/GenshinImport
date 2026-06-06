const express = require('express');
const pool = require('../config/db');
const { verifyBearerToken } = require('../middleware/auth');

const router = express.Router();

// Get user's purchase orders
router.get('/user/:userId', verifyBearerToken, async (req, res) => {
  if (req.user.id !== Number(req.params.userId)) {
    return res.status(403).json({ message: 'Unauthorized.' });
  }

  try {
    const [orders] = await pool.query(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
      [req.params.userId]
    );
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch orders.', error: error.message });
  }
});

// Create purchase order
router.post('/', verifyBearerToken, async (req, res) => {
  const { weapon_id, quantity } = req.body;

  if (!weapon_id || !quantity) {
    return res.status(400).json({ message: 'weapon_id and quantity are required.' });
  }

  const quantityNum = Number(quantity);
  if (Number.isNaN(quantityNum) || quantityNum <= 0) {
    return res.status(400).json({ message: 'quantity must be a number > 0.' });
  }

  try {
    // Get weapon to calculate total price
    const [weapons] = await pool.query('SELECT * FROM weapons WHERE id = ? LIMIT 1', [weapon_id]);

    if (weapons.length === 0) {
      return res.status(404).json({ message: 'Weapon not found.' });
    }

    const weapon = weapons[0];
    const totalPrice = weapon.price * quantityNum;

    // Create order
    const [result] = await pool.query(
      'INSERT INTO orders (user_id, weapon_id, quantity, total_price) VALUES (?, ?, ?, ?)',
      [req.user.id, weapon_id, quantityNum, totalPrice]
    );

    res.status(201).json({ message: 'Order created.', id: result.insertId });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create order.', error: error.message });
  }
});

module.exports = router;
