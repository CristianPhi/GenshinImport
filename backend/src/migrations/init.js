const pool = require('../config/db');

async function runMigrations() {
  const conn = await pool.getConnection();

  try {
    // ── users ──────────────────────────────────────────────────────────────
    await conn.query(`
      CREATE TABLE IF NOT EXISTS users (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        username   VARCHAR(100) NOT NULL,
        email      VARCHAR(150) NOT NULL UNIQUE,
        password   VARCHAR(255) NOT NULL,
        role       ENUM('user', 'admin') NOT NULL DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // ── auth_tokens ────────────────────────────────────────────────────────
    await conn.query(`
      CREATE TABLE IF NOT EXISTS auth_tokens (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        user_id    INT NOT NULL,
        token      VARCHAR(255) NOT NULL UNIQUE,
        expired_at DATETIME,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    // ── weapons ────────────────────────────────────────────────────────────
    // FIX: image column changed to LONGTEXT to support base64-encoded images
    await conn.query(`
      CREATE TABLE IF NOT EXISTS weapons (
        id          INT AUTO_INCREMENT PRIMARY KEY,
        name        VARCHAR(150) NOT NULL,
        type        VARCHAR(100) NOT NULL,
        description TEXT,
        stock       INT NOT NULL DEFAULT 0,
        price       DECIMAL(12,2) NOT NULL,
        image       LONGTEXT,
        created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Migrate existing image column to LONGTEXT if it was VARCHAR(500)
    await conn.query(`
      ALTER TABLE weapons MODIFY COLUMN image LONGTEXT
    `).catch(() => {}); // ignore if already correct type

    // ── orders ─────────────────────────────────────────────────────────────
    await conn.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id          INT AUTO_INCREMENT PRIMARY KEY,
        user_id     INT NOT NULL,
        weapon_id   INT NOT NULL,
        quantity    INT NOT NULL DEFAULT 1,
        total_price DECIMAL(12,2) NOT NULL,
        status      ENUM('pending', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
        created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
      )
    `);

    // FIX: admin seed uses email='admin' and password='admin123'
    await conn.query(`
      INSERT INTO users (username, email, password, role)
      SELECT 'Admin', 'admin', 'admin123', 'admin'
      WHERE NOT EXISTS (
        SELECT 1 FROM users WHERE email = 'admin'
      )
    `);

    // ── seed: test user ────────────────────────────────────────────────────
    await conn.query(`
      INSERT INTO users (username, email, password, role)
      SELECT 'testuser', 'user@genshinimport.com', 'user123', 'user'
      WHERE NOT EXISTS (
        SELECT 1 FROM users WHERE email = 'user@genshinimport.com'
      )
    `);

    // ── seed: sample weapons ───────────────────────────────────────────────
    const [existingWeapons] = await conn.query('SELECT COUNT(*) AS cnt FROM weapons');
    if (existingWeapons[0].cnt === 0) {
      await conn.query(`
        INSERT INTO weapons (name, type, description, stock, price, image) VALUES
        ('Aquila Favonia',      'Sword',    'A sword that gleams like the holy falcon of Favonius.',                       10, 150000.00, NULL),
        ('Wolf\\'s Gravestone', 'Claymore', 'A longsword that used to belong to the Wolf Knight of Mondstadt.',           5,  200000.00, NULL),
        ('Skyward Harp',        'Bow',      'A bow that was once used by a god to play the melody of the sky.',           8,  175000.00, NULL),
        ('Lost Prayer',         'Catalyst', 'An ancient catalyst with four pages, each containing a different prayer.',   6,  180000.00, NULL),
        ('Primordial Jade',     'Polearm',  'A polearm carved from primordial jade, said to have been used by the gods.', 7,  190000.00, NULL)
      `);
    }

    console.log('Database initialized successfully.');
  } finally {
    conn.release();
  }
}

module.exports = runMigrations;
