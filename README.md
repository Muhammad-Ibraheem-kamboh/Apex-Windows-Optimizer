# Apex Windows Optimizer Pro ⚡

An ultra-lightweight, zero-dependency Windows performance suite and hardware optimizer built with **Node.js**, **PowerShell Core**, and a modern web dashboard.

---

## 🌟 Key Features

- **⚡ RAM Flushing & Working Set Optimization**: Reclaims gigabytes of fragmented standby cache and RAM without crashing active applications.
- **🛡️ Auto-Pilot Watchdog**: Background background threshold monitoring (Auto-RAM flush, Battery Swell Alert at 85% safe cap, and periodic temporary file cleanups).
- **🚀 LLM & Dev Power Mode**: Stops resource-heavy background virtualization (`vmmemWSL`) and non-essential services on low-spec hardware (8 GB RAM / Dual-Core CPUs) to maximize compute for AI workloads.
- **🧹 Storage Sweeper & SSD TRIM**: Scans and cleans temp folders, logs, crash dumps, and issues Windows SSD `ReTrim` calls.
- **🔌 Native Desktop Launcher**: Launches quietly in native app mode (`launch.vbs` & `start.cmd`) without leaving bulky terminal windows open.
- **🔒 Zero Third-Party Node Modules**: Zero bloated `node_modules` — runs purely using Node's standard `http`, `fs`, `child_process`, and native Windows PowerShell APIs.

---

## 💻 Tech Stack

- **Backend**: Native Node.js HTTP Server (`server.js`) bound strictly to `127.0.0.1`
- **Engine**: PowerShell 5.1+ automation scripts (`engine.ps1`)
- **Frontend**: Lightweight Vanilla HTML5 / Modern CSS / Vanilla JS dashboard
- **Host OS**: Windows 10 / Windows 11 (64-bit)

---

## 🚀 Quick Start

### 1. Prerequisites
- **Node.js** (v16.x or higher)
- **Windows 10/11** with PowerShell

### 2. Launching the Suite
Double-click `start.cmd` or run:
```cmd
node server.js
```
Then open your browser at:
```
http://127.0.0.1:48888
```

---

## 🛡️ Security & Zero-Trust Audit

- **Localhost Only**: The internal server listens strictly on `127.0.0.1:48888`. It does not accept remote network traffic or expose open WAN ports.
- **Zero Secrets**: Contains no hardcoded tokens, passwords, personal paths, or credentials.
- **Clean Execution**: PowerShell commands run with `-NoProfile` and parameterized execution.

---

## 📜 License
MIT License. Created by [Muhammad Ibrahim (Abdaal)](https://github.com/).
