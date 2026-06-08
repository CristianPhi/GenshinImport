const { execSync } = require('child_process');

const PORT = process.env.PORT || 3007;

if (process.platform !== 'win32') {
  process.exit(0);
}

try {
  const out = execSync(`netstat -ano | findstr :${PORT}`, { encoding: 'utf8' });
  const pids = new Set();

  for (const line of out.split('\n')) {
    if (!line.includes('LISTENING')) continue;
    const pid = line.trim().split(/\s+/).pop();
    if (pid && pid !== '0') pids.add(pid);
  }

  for (const pid of pids) {
    try {
      execSync(`taskkill /PID ${pid} /F`, { stdio: 'ignore' });
      console.log(`Port ${PORT}: stopped process ${pid}`);
    } catch {
      
    }
  }
} catch {
}
