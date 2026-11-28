const http = require('http');
const fs = require('fs');
const path = require('path');
const { execFile } = require('child_process');

const PORT = 48888;
const ENGINE_PS1 = path.join(__dirname, 'engine.ps1');
const PUBLIC_DIR = path.join(__dirname, 'public');
const CONFIG_FILE = path.join(__dirname, 'autopilot.config.json');

// Default Auto-Pilot State (persisted to autopilot.config.json)
const DEFAULT_AUTOPILOT = {
    enabled: true,
    autoRam: true,
    ramThreshold: 75,
    autoCleanStorage: true,
    cleanIntervalHours: 6,
    batteryCapAlarm: true,
    batteryCap: 85,
    lastCleanTime: Date.now()
};

function loadAutoPilotConfig() {
    try {
        if (fs.existsSync(CONFIG_FILE)) {
            const saved = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
            return { ...DEFAULT_AUTOPILOT, ...saved };
        }
    } catch {}
    return { ...DEFAULT_AUTOPILOT };
}

function saveAutoPilotConfig(cfg) {
    try {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify(cfg, null, 2));
    } catch {}
}

const autoPilotConfig = loadAutoPilotConfig();
let cachedStaticInfo = null;
let lastBatteryAlertTime = 0;

const activityLogs = [
    `[${new Date().toLocaleTimeString()}] Apex Windows Optimizer Engine Initialized`
];

function logActivity(msg) {
    const time = new Date().toLocaleTimeString();
    activityLogs.unshift(`[${time}] ${msg}`);
    if (activityLogs.length > 50) activityLogs.pop();
}

const HEAVY_ACTIONS = new Set([
    'BackupFiles',
    'DeepCleanCache',
    'CleanStorage',
    'OptimizeSSD',
    'LLMMaxBoost',
    'GetStaticInfo'
]);

function runEngine(action, args = {}) {
    return new Promise((resolve, reject) => {
        const psArgs = [
            '-ExecutionPolicy', 'Bypass',
            '-NoProfile',
            '-File', ENGINE_PS1,
            '-Action', action
        ];

        if (args.Target) psArgs.push('-Target', String(args.Target));
        if (args.Mode) psArgs.push('-Mode', String(args.Mode));

        const timeoutMs = HEAVY_ACTIONS.has(action) ? 120000 : 20000;

        execFile('powershell.exe', psArgs, { windowsHide: true, timeout: timeoutMs }, (error, stdout) => {
            if (error) {
                return reject(error);
            }
            try {
                const parsed = JSON.parse(stdout.trim());
                resolve(parsed);
            } catch {
                resolve({ raw: stdout.trim() });
            }
        });
    });
}

async function getStaticHardwareInfo() {
    if (cachedStaticInfo) return cachedStaticInfo;
    try {
        cachedStaticInfo = await runEngine('GetStaticInfo');
    } catch {
        cachedStaticInfo = {};
    }
    return cachedStaticInfo;
}

// Pre-warm static hardware cache on startup
getStaticHardwareInfo();

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

        // 2. Battery Swell Protection Alert (>85% while charging, throttled to once per 15 min)
        if (autoPilotConfig.batteryCapAlarm && stats.battery && stats.battery.present && stats.battery.status.includes('Charging')) {
            if (stats.battery.percent >= autoPilotConfig.batteryCap && (Date.now() - lastBatteryAlertTime) > 15 * 60 * 1000) {
                lastBatteryAlertTime = Date.now();
                logActivity(`Battery Guard Alert: Battery reached ${stats.battery.percent}% safe cap. Unplug recommended.`);
            }
        }

        // 3. Auto Storage Cleanup
        const hoursSinceClean = (Date.now() - autoPilotConfig.lastCleanTime) / (3600 * 1000);
        if (autoPilotConfig.autoCleanStorage && hoursSinceClean >= autoPilotConfig.cleanIntervalHours) {
            autoPilotConfig.lastCleanTime = Date.now();
            saveAutoPilotConfig(autoPilotConfig);
            const clean = await runEngine('CleanStorage');
            logActivity(`Auto-Pilot: Routine storage sweep cleaned ${clean.cleanedMb} MB temporary files.`);
        }
    } catch {
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

    const sendJson = (data, code = 200) => {
        res.writeHead(code, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    };

    const sendEngineResult = (result, logPrefix) => {
        if (logPrefix && result && result.message) {
            logActivity(`${logPrefix}: ${result.message}`);
        }
        const status = (result && result.success === false) ? 400 : 200;
        sendJson(result, status);
    };

    const getBody = () => new Promise(resolve => {
        let body = '';
        req.on('data', chunk => {
            if (body.length < 65536) body += chunk;
        });
        req.on('end', () => {
            try { resolve(JSON.parse(body || '{}')); }
            catch { resolve({}); }
        });
    });

    try {
        // Telemetry & Hardware Info
        if (pathname === '/api/stats') {
            const [stats, staticInfo] = await Promise.all([
                runEngine('GetStats'),
                getStaticHardwareInfo()
            ]);
            if (stats.ram && staticInfo.ram) {
                stats.ram.speedMhz = staticInfo.ram.speedMhz;
                stats.ram.manufacturer = staticInfo.ram.manufacturer;
            }
            if (staticInfo.gpu) stats.gpu = staticInfo.gpu;
            if (stats.disk && staticInfo.disk) {
                stats.disk.mediaType = staticInfo.disk.mediaType;
                stats.disk.model = staticInfo.disk.model;
            }
            stats.isAdmin = Boolean(staticInfo.isAdmin);
            sendJson(stats);
            return;
        }

        // Memory
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

        // Storage
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
            sendEngineResult(result, 'SSD TRIM');
            return;
        }

        if (pathname === '/api/storage/hibernation' && req.method === 'POST') {
            const body = await getBody();
            const mode = ['reduced', 'off', 'full'].includes(body.mode) ? body.mode : 'reduced';
            const result = await runEngine('SetHibernation', { Mode: mode });
            sendEngineResult(result, 'Hibernation');
            return;
        }

        // Power
        if (pathname === '/api/power/plan' && req.method === 'POST') {
            const body = await getBody();
            const plan = ['high', 'balanced', 'saver'].includes(body.plan) ? body.plan : 'balanced';
            const result = await runEngine('SetPowerPlan', { Mode: plan });
            sendEngineResult(result, 'Power Plan');
            return;
        }

        // Boost Modes
        if (pathname === '/api/boost/hyper' && req.method === 'POST') {
            const flush = await runEngine('FlushRam');
            const bloat = await runEngine('KillBloat');
            logActivity(`HYPER BOOST: Freed ${flush.freedMb} MB RAM & halted ${bloat.killedCount} bloat processes!`);
            sendJson({ success: true, freedMb: flush.freedMb, killedCount: bloat.killedCount });
            return;
        }

        if (pathname === '/api/net/flush-dns' && req.method === 'POST') {
            const result = await runEngine('FlushDNS');
            sendEngineResult(result, 'Network');
            return;
        }

        if (pathname === '/api/boost/game-mode' && req.method === 'POST') {
            const result = await runEngine('GameBoost');
            sendEngineResult(result, 'Gaming Boost');
            return;
        }

        if (pathname === '/api/boost/standard-mode' && req.method === 'POST') {
            const result = await runEngine('RestoreStandardMode');
            sendEngineResult(result, 'System Mode');
            return;
        }

        if (pathname === '/api/boost/llm-max' && req.method === 'POST') {
            const result = await runEngine('LLMMaxBoost');
            sendEngineResult(result, 'LLM Max Power');
            return;
        }

        if (pathname === '/api/boost/restore-services' && req.method === 'POST') {
            const result = await runEngine('RestoreServices');
            sendEngineResult(result, 'Services');
            return;
        }

        // System Tweaks
        if (pathname === '/api/tweaks/snappiness' && req.method === 'POST') {
            const result = await runEngine('TweakSnappiness');
            sendEngineResult(result, 'UI Snappiness');
            return;
        }

        if (pathname === '/api/tweaks/tcp' && req.method === 'POST') {
            const result = await runEngine('TweakTCP');
            sendEngineResult(result, 'TCP Tuning');
            return;
        }

        if (pathname === '/api/tweaks/transparency' && req.method === 'POST') {
            const result = await runEngine('TweakTransparency');
            sendEngineResult(result, 'Transparency');
            return;
        }

        // Window Controls
        if (pathname === '/api/window/control' && req.method === 'POST') {
            const body = await getBody();
            const mode = ['minimize', 'maximize', 'close'].includes(body.action) ? body.action : '';
            if (!mode) {
                sendJson({ success: false, error: 'Invalid window action' }, 400);
                return;
            }
            const result = await runEngine('WindowControl', { Mode: mode });
            sendJson(result);
            return;
        }

        // Custom Desktop Utilities Suite
        if (pathname === '/api/utilities/backup' && req.method === 'POST') {
            const result = await runEngine('BackupFiles');
            sendEngineResult(result, 'Backup Engine');
            return;
        }

        if (pathname === '/api/utilities/deep-clean' && req.method === 'POST') {
            const result = await runEngine('DeepCleanCache');
            sendEngineResult(result, 'Deep Cache Purge');
            return;
        }

        if (pathname === '/api/utilities/dev-check') {
            const result = await runEngine('CheckDevEnv');
            sendJson(result);
            return;
        }

        if (pathname === '/api/utilities/dev-setup' && req.method === 'POST') {
            const result = await runEngine('SetupDevEnv');
            sendEngineResult(result, 'Dev Environment');
            return;
        }

        if (pathname === '/api/utilities/restart-explorer' && req.method === 'POST') {
            const result = await runEngine('RestartExplorer');
            sendEngineResult(result, 'Desktop Rescue');
            return;
        }

        if (pathname === '/api/utilities/reset-network' && req.method === 'POST') {
            const result = await runEngine('ResetNetworkStack');
            sendEngineResult(result, 'Network Rescue');
            return;
        }

        // Auto-Pilot Configuration
        if (pathname === '/api/autopilot') {
            if (req.method === 'POST') {
                const body = await getBody();
                if (typeof body.enabled === 'boolean') autoPilotConfig.enabled = body.enabled;
                if (typeof body.autoRam === 'boolean') autoPilotConfig.autoRam = body.autoRam;
                if (typeof body.autoCleanStorage === 'boolean') autoPilotConfig.autoCleanStorage = body.autoCleanStorage;
                if (typeof body.batteryCapAlarm === 'boolean') autoPilotConfig.batteryCapAlarm = body.batteryCapAlarm;
                if (typeof body.ramThreshold === 'number' && Number.isFinite(body.ramThreshold)) {
                    autoPilotConfig.ramThreshold = Math.min(95, Math.max(50, Math.round(body.ramThreshold)));
                }
                saveAutoPilotConfig(autoPilotConfig);
                logActivity(`Auto-Pilot configuration saved (RAM Threshold: ${autoPilotConfig.ramThreshold}%).`);
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
        sendJson({ success: false, error: err.message }, 500);
    }
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`Apex Windows Optimizer running at http://127.0.0.1:${PORT}`);
});
