const http = require('http');

function testUrl(path, method = 'GET', postData = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: 48888,
      path: path,
      method: method,
      headers: { 'Content-Type': 'application/json' }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({ path, status: res.statusCode, data: data.slice(0, 160) });
      });
    });

    req.on('error', reject);
    if (postData) req.write(JSON.stringify(postData));
    req.end();
  });
}

async function run() {
  const tests = [
    { path: '/', method: 'GET' },
    { path: '/style.css', method: 'GET' },
    { path: '/app.js', method: 'GET' },
    { path: '/api/stats', method: 'GET' },
    { path: '/api/tweaks/snappiness', method: 'POST' },
    { path: '/api/tweaks/tcp', method: 'POST' },
    { path: '/api/tweaks/transparency', method: 'POST' }
  ];

  for (const t of tests) {
    try {
      const res = await testUrl(t.path, t.method);
      console.log(`[PASS] ${t.method} ${res.path} -> HTTP ${res.status}: ${res.data.replace(/\s+/g, ' ')}`);
    } catch (e) {
      console.log(`[FAIL] ${t.method} ${t.path} -> ${e.message}`);
    }
  }
}

run();
