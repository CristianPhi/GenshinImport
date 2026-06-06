const fs = require('fs');
const path = require('path');
const pool = require('./src/config/db');

async function seed() {
  const sql = fs.readFileSync(path.join(__dirname, 'setup.sql'), 'utf8');
  const statements = sql
    .split(';')
    .map((s) =>
      s
        .split('\n')
        .filter((line) => !line.trim().startsWith('--'))
        .join('\n')
        .trim()
    )
    .filter((s) => s.length > 0);

  for (const statement of statements) {
    await pool.query(statement);
  }

  console.log('Seed selesai.');
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed gagal:', err.message);
  process.exit(1);
});
