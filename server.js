const http = require('http');
const fs = require('fs');
const path = require('path');
const { execFile, exec } = require('child_process');

const PORT = 48888;
const ENGINE_PS1 = path.join(__dirname, 'engine.ps1');
const PUBLIC_DIR = path.join(__dirname, 'public');

// Auto-Pilot State
const autoPilotConfig = {
    enabled: true,
    autoRam: true,
    ramThreshold: 75,
    autoCleanStorage: true,
    cleanIntervalHours: 6,
    batteryCapAlarm: true,
    batteryCap: 85,
    lastCleanTime: Date.now()
};

const activityLogs = [
    `[${new Date().toLocaleTimeString()}] Apex Windows Optimizer Engine Initialized`
];

function logActivity(msg) {
    const time = new Date().toLocaleTimeString();
    activityLogs.unshift(`[${time}] ${msg}`);
    if (activityLogs.length > 50) activityLogs.pop();
}

function runEngine(action, args = {}) {
    return new Promise((resolve, reject) => {
        const psArgs = [
            '-ExecutionPolicy', 'Bypass',
            '-NoProfile',
            '-File', ENGINE_PS1,
            '-Action', action
        ];

        if (args.Target) psArgs.push('-Target', args.Target);
        if (args.Mode) psArgs.push('-Mode', args.Mode);

        execFile('powershell.exe', psArgs, { windowsHide: true, timeout: 20000 }, (error, stdout, stderr) => {
            if (error) {
                return reject(error);
            }
            try {
                const parsed = JSON.parse(stdout.trim());
                resolve(parsed);
            } catch (e) {
                resolve({ raw: stdout.trim() });
            }
        });
    });
}

// Background Auto-Pilot Watchdog (every 2 minutes to save CPU/battery)
setInterval(async () => {
    if (!autoPilotConfig.enabled) return;

    try {
        const stats = await runEngine('GetStats');

        // 1. Auto RAM Flush if threshold exceeded
        if (autoPilotConfig.autoRam && stats.ram && stats.ram.percent >= autoPilotConfig.ramThreshold) {
            const flush = await runEngine('FlushRam');
            logActivity(`Auto-Pilot: RAM load was ${stats.ram.percent}%. Freed ${flush.freedMb} MB RAM automatically.`);
        }

        // 2. Battery Swell Protection Alert (>85% while charging)
        if (autoPilotConfig.batteryCapAlarm && stats.battery && stats.battery.status.includes('Charging')) {
            if (stats.battery.percent >= autoPilotConfig.batteryCap) {
                logActivity(`Battery Guard Alert: Battery reached ${stats.battery.percent}% safe cap. Unplug recommended.`);
            }
        }

        // 3. Auto Storage Cleanup
        const hoursSinceClean = (Date.now() - autoPilotConfig.lastCleanTime) / (3600 * 1000);
        if (autoPilotConfig.autoCleanStorage && hoursSinceClean >= autoPilotConfig.cleanIntervalHours) {
            autoPilotConfig.lastCleanTime = Date.now();
            const clean = await runEngine('CleanStorage');
            logActivity(`Auto-Pilot: Routine storage sweep cleaned ${clean.cleanedMb} MB temporary files.`);
        }
    } catch (e) {
        // Silently continue watchdog loop
    }
}, 120000);

// HTTP Server
const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const pathname = url.pathname;

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    // Helper to send JSON
    const sendJson = (data, code = 200) => {
        res.writeHead(code, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    };

    // Helper to read POST body
    const getBody = () => new Promise(resolve => {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try { resolve(JSON.parse(body || '{}')); }
            catch { resolve({}); }
        });
    });

    try {
        // API Routes
        if (pathname === '/api/stats') {
            const stats = await runEngine('GetStats');
            sendJson(stats);
            return;
        }

        if (pathname === '/api/ram/flush' && req.method === 'POST') {
            const result = await runEngine('FlushRam');
            logActivity(`Manual Flush: Recovered ${result.freedMb} MB RAM.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/ram/kill-bloat' && req.method === 'POST') {
            const result = await runEngine('KillBloat');
            logActivity(`Bloat Purge: Terminated ${result.killedCount} background bloat tasks.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/storage/scan') {
            const result = await runEngine('ScanStorage');
            sendJson(result);
            return;
        }

        if (pathname === '/api/storage/clean' && req.method === 'POST') {
            const result = await runEngine('CleanStorage');
            logActivity(`Storage Sweep: Cleared ${result.cleanedMb} MB junk files.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/storage/trim' && req.method === 'POST') {
            const result = await runEngine('OptimizeSSD');
            logActivity(`SSD TRIM: ReTrim maintenance command issued.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/storage/hibernation' && req.method === 'POST') {
            const body = await getBody();
            const result = await runEngine('SetHibernation', { Mode: body.mode || 'reduced' });
            logActivity(`Hibernation: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/power/plan' && req.method === 'POST') {
            const body = await getBody();
            const result = await runEngine('SetPowerPlan', { Mode: body.plan || 'balanced' });
            logActivity(`Power Plan: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/boost/hyper' && req.method === 'POST') {
            const flush = await runEngine('FlushRam');
            const bloat = await runEngine('KillBloat');
            logActivity(`HYPER BOOST: Freed ${flush.freedMb} MB RAM & halted ${bloat.killedCount} bloat processes!`);
            sendJson({ success: true, freedMb: flush.freedMb, killedCount: bloat.killedCount });
            return;
        }

        if (pathname === '/api/net/flush-dns' && req.method === 'POST') {
            const result = await runEngine('FlushDNS');
            logActivity(`Network: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/boost/game-mode' && req.method === 'POST') {
            const result = await runEngine('GameBoost');
            logActivity(`Gaming Boost: Freed ${result.freedMb} MB RAM & optimized thread priority.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/boost/standard-mode' && req.method === 'POST') {
            const result = await runEngine('RestoreStandardMode');
            logActivity(`System Mode: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/boost/llm-max' && req.method === 'POST') {
            const result = await runEngine('LLMMaxBoost');
            logActivity(`LLM Max Power Mode: Freed ${result.freedMb} MB RAM, WSL stopped, CPU: ${result.cpuSpeed}.`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/boost/restore-services' && req.method === 'POST') {
            const result = await runEngine('RestoreServices');
            logActivity(`Services: ${result.message}`);
            sendJson(result);
            return;
        }

        // Custom Desktop Utilities Suite
        if (pathname === '/api/utilities/backup' && req.method === 'POST') {
            const result = await runEngine('BackupFiles');
            logActivity(`Backup Engine: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/deep-clean' && req.method === 'POST') {
            const result = await runEngine('DeepCleanCache');
            logActivity(`Deep Cache Purge: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/dev-check') {
            const result = await runEngine('CheckDevEnv');
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/dev-setup' && req.method === 'POST') {
            const result = await runEngine('SetupDevEnv');
            logActivity(`Dev Environment: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/restart-explorer' && req.method === 'POST') {
            const result = await runEngine('RestartExplorer');
            logActivity(`Desktop Rescue: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/reset-network' && req.method === 'POST') {
            const result = await runEngine('ResetNetworkStack');
            logActivity(`Network Rescue: ${result.message}`);
            sendJson(result);
            return;
        }

        if (pathname === '/api/autopilot') {
            if (req.method === 'POST') {
                const body = await getBody();
                Object.assign(autoPilotConfig, body);
                logActivity(`Auto-Pilot configuration updated (Threshold: ${autoPilotConfig.ramThreshold}%).`);
                sendJson({ success: true, config: autoPilotConfig });
            } else {
                sendJson(autoPilotConfig);
            }
            return;
        }

        if (pathname === '/api/autopilot/logs') {
            sendJson({ logs: activityLogs });
            return;
        }

        // Static Files Serving
        const reqPath = pathname === '/' ? 'index.html' : pathname.replace(/^\/+/, '');
        let filePath = path.resolve(PUBLIC_DIR, reqPath);
        if (!filePath.startsWith(PUBLIC_DIR) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
            filePath = path.join(PUBLIC_DIR, 'index.html');
        }

        const ext = path.extname(filePath).toLowerCase();
        const contentTypes = {
            '.html': 'text/html',
            '.js': 'application/javascript',
            '.css': 'text/css',
            '.json': 'application/json',
            '.svg': 'image/svg+xml',
            '.png': 'image/png',
            '.ico': 'image/x-icon'
        };

        const contentType = contentTypes[ext] || 'application/octet-stream';
        const fileContent = fs.readFileSync(filePath);
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(fileContent);

    } catch (err) {
        sendJson({ error: err.message }, 500);
    }
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`Apex Windows Optimizer running at http://127.0.0.1:${PORT}`);
});
