const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const pool = require('./config/db');
const runMigrations = require('./migrations/init');
const authRoutes = require('./routes/auth');
const weaponRoutes = require('./routes/weapons');
const orderRoutes = require('./routes/orders');

const app = express();
const PORT = Number(process.env.PORT || 3007);

app.use(cors());
app.use(express.json());

app.use((req, _res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

app.get('/api/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ message: 'Backend is running and DB is connected.' });
  } catch (error) {
    res.status(500).json({
      message: 'Backend running but DB connection failed.',
      error: error.message,
    });
  }
});

app.get('/', (_req, res) => {
  res.send('Genshin Import Backend — use /api/* endpoints');
});

app.use('/api/auth', authRoutes);
app.use('/api/weapons', weaponRoutes);
app.use('/api/orders', orderRoutes);

app.use((_req, res) => {
  res.status(404).json({ message: 'Not found' });
});

app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Internal server error', error: err.message });
});

runMigrations()
  .then(() => console.log('Database initialized.'))
  .catch((err) => console.error('Migration error (server will still start):', err.message));

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Android emulator: http://10.0.2.2:${PORT}/api`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} sudah dipakai. Cek .env — PORT harus beda dari DB_PORT (MySQL).`);
  } else {
    console.error('Server error:', err.message);
  }
  process.exit(1);
});

function shutdown() {
  console.log('Shutting down server...');
  server.close(() => {
    pool.end().then(() => process.exit(0));
  });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
