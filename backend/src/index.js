const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const pool = require('./config/db');
const authRoutes = require('./routes/auth');
const weaponRoutes = require('./routes/weapons');
const orderRoutes = require('./routes/orders');

const app = express();
const PORT = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

// Simple request logger (development)
app.use((req, _res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    next();
});

// Health check endpoint
app.get('/api/health', async (_req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ message: 'Backend is running and DB is connected.' });
    } catch (error) {
        res.status(500).json({ message: 'Backend running but DB connection failed.', error: error.message });
    }
});

// Root info
app.get('/', (_req, res) => {
    res.send('Genshin Import Backend — use /api/* endpoints');
});

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/weapons', weaponRoutes);
app.use('/api/orders', orderRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({ message: 'Not found' });
});

// Error handler
app.use((err, _req, res, _next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
});

const server = app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});

// Graceful shutdown
function shutdown() {
    console.log('Shutting down server...');
    server.close(() => {
        pool.end().then(() => {
            console.log('DB pool closed. Bye.');
            process.exit(0);
        });
    });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
