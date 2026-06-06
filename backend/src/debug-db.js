const net = require('net');
const dns = require('dns');
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const host = process.env.DB_HOST || '127.0.0.1';
const port = Number(process.env.DB_PORT || 3307);
const user = process.env.DB_USER || 'root';
const password = process.env.DB_PASSWORD || '';
const database = process.env.DB_NAME || 'genshinimport';

console.log('Debug DB connection');
console.log({ host, port, user, database });

// DNS lookup
dns.lookup(host, { all: true }, (err, addresses) => {
  if (err) {
    console.error('DNS lookup error:', err.message);
  } else {
    console.log('DNS addresses:', addresses);
  }

  // TCP socket test
  const socket = new net.Socket();
  let connected = false;
  socket.setTimeout(5000);
  socket.on('connect', () => {
    connected = true;
    console.log(`TCP connect OK to ${host}:${port}`);
    socket.end();
  });
  socket.on('timeout', () => {
    console.error('TCP connect timeout');
    socket.destroy();
    runMysqlTest();
  });
  socket.on('error', (e) => {
    console.error('TCP socket error:', e.message);
    socket.destroy();
    runMysqlTest();
  });
  socket.on('close', () => {
    if (!connected) {
      console.log('TCP socket closed (not connected)');
    }
    // proceed to MySQL test
  });

  socket.connect(port, host);
});

async function runMysqlTest() {
  console.log('Attempting MySQL connection using mysql2...');
  try {
    const conn = await mysql.createConnection({
      host,
      port,
      user,
      password,
      database,
      connectTimeout: 10000,
    });

    const [rows] = await conn.query('SELECT 1 as ok');
    console.log('MySQL query result:', rows);
    await conn.end();
    console.log('MySQL connection success');
  } catch (err) {
    console.error('MySQL connection error:');
    console.error(err && err.stack ? err.stack : err);
  }
}
