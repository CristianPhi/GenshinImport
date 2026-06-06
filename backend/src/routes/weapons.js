const express = require('express');
const pool = require('../config/db');
const { verifyBearerToken, verifyAdmin } = require('../middleware/auth');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM weapons ORDER BY id DESC');
    const weapons = rows.map((weapon) => ({
      ...weapon,
      status: weapon.stock === 0 ? 'sold_out' : 'available',
      image: weapon.stock === 0 ? null : weapon.image,
    }));
    res.json(weapons);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch weapons.', error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM weapons WHERE id = ? LIMIT 1', [req.params.id]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Weapon not found.' });
    }

    return res.json(rows[0]);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch weapon detail.', error: error.message });
  }
});

router.post('/', verifyBearerToken, verifyAdmin, async (req, res) => {
  const { name, type, description, stock, price, image } = req.body;

  if (!name || !type || !description) {
    return res.status(400).json({ message: 'name, type, and description are required.' });
  }

  const stockNumber = Number(stock);
  const priceNumber = Number(price);

  if (Number.isNaN(stockNumber) || stockNumber < 0) {
    return res.status(400).json({ message: 'stock must be a number and >= 0.' });
  }

  if (Number.isNaN(priceNumber) || priceNumber <= 0) {
    return res.status(400).json({ message: 'price must be a number and > 0.' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO weapons (name, type, description, stock, price, image) VALUES (?, ?, ?, ?, ?, ?)',
      [name, type, description, stockNumber, priceNumber, image || null]
    );

    res.status(201).json({ message: 'Weapon created.', id: result.insertId });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create weapon.', error: error.message });
  }
});

router.put('/:id', verifyBearerToken, verifyAdmin, async (req, res) => {
  const { name, type, description, stock, price, image } = req.body;

  if (!name || !type || !description) {
    return res.status(400).json({ message: 'name, type, and description are required.' });
  }

  const stockNumber = Number(stock);
  const priceNumber = Number(price);

  if (Number.isNaN(stockNumber) || stockNumber < 0) {
    return res.status(400).json({ message: 'stock must be a number and >= 0.' });
  }

  if (Number.isNaN(priceNumber) || priceNumber <= 0) {
    return res.status(400).json({ message: 'price must be a number and > 0.' });
  }

  try {
    const [result] = await pool.query(
      'UPDATE weapons SET name = ?, type = ?, description = ?, stock = ?, price = ?, image = ? WHERE id = ?',
      [name, type, description, stockNumber, priceNumber, image || null, req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Weapon not found.' });
    }

    return res.json({ message: 'Weapon updated.' });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to update weapon.', error: error.message });
  }
});

router.delete('/:id', verifyBearerToken, verifyAdmin, async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM weapons WHERE id = ?', [req.params.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Weapon not found.' });
    }

    return res.json({ message: 'Weapon deleted.' });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to delete weapon.', error: error.message });
  }
});

module.exports = router;
