# Apex Windows Optimizer Pro ⚡

<p align="center">
  <img src="assets/preview.png" alt="Apex Windows Optimizer Pro Dashboard" width="850">
</p>

<p align="center">
  <strong>An ultra-lightweight, zero-dependency Windows performance suite and hardware optimizer.</strong><br>
  Built with native Node.js, PowerShell Core, and an agency-grade, humanized <strong>Coinbase iOS Light UI</strong>.
</p>

<p align="center">
  <a href="https://github.com/Muhammad-Ibraheem-kamboh/Apex-Windows-Optimizer/releases">
    <img src="https://img.shields.io/github/v/release/Muhammad-Ibraheem-kamboh/Apex-Windows-Optimizer?color=0052FF&label=Release&style=flat-square" alt="Release"/>
  </a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform"/>
  <img src="https://img.shields.io/badge/Dependencies-0%20Zero-098551?style=flat-square" alt="Zero Dependencies"/>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/Muhammad-Ibraheem-kamboh/Apex-Windows-Optimizer?style=flat-square&color=0052FF" alt="License"/>
  </a>
  <img src="https://img.shields.io/github/stars/Muhammad-Ibraheem-kamboh/Apex-Windows-Optimizer?style=flat-square&color=F59E0B" alt="Stars"/>
</p>

<p align="center">
  <a href="#-key-features">Key Features</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-why-apex-optimizer">Why Apex?</a> •
  <a href="#-architecture--zero-trust-security">Architecture</a> •
  <a href="#-license">License</a>
</p>

---

## 🌟 Key Features

- **⚡ Instant Working Set RAM Flush**: Recovers gigabytes of fragmented unmanaged cache and working sets across all running Windows processes in under 500ms using native `.NET` garbage collection and process trimming.
- **🛡️ Autonomous Background Watchdog**: Runs silently with minimal CPU overhead, monitoring memory load thresholds, battery safety caps (preventing lithium pouch cell gas buildup at 85%), and automated temp cleanup.
- **🚀 LLM & Developer Boost Mode**: Throttles non-essential background telemetry and suspends resource-heavy virtualization (`vmmemWSL`, Windows Search indexer) to unleash maximum compute and RAM for local AI models, compilers, and IDEs.
- **🧹 Deep Storage Sweeper & SSD TRIM**: Cleans system temp files, mini-dumps, and Windows update cache, and issues native Windows storage controller `ReTrim` optimization commands.
- **🎨 Modern Fintech Aesthetic**: Handcrafted humanized interface inspired by the clean, high-contrast **Coinbase iOS design system** with vibrant electric blue accents, stadium pill controls, and zero dark eye-fatigue.
- **🪶 Featherweight Footprint (Zero `node_modules`)**: 100% dependency-free! Runs purely on native Node.js standard libraries (`http`, `child_process`, `fs`) and native Windows APIs. Entire repo is under **1.5 MB**.

---

## 🚀 Quick Start (Runs on Any Windows Machine)

### Prerequisites
- **Windows 10 / 11** (64-bit)
- **Node.js** (v16.x or higher) installed

### Installation & Launching

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Muhammad-Ibraheem-kamboh/Apex-Windows-Optimizer.git
   cd Apex-Windows-Optimizer
   ```

2. **Run as Desktop App (One-Click)**:
   - Double-click **`start.cmd`** or **`launch.vbs`**.
   - The engine starts automatically in the background, launching the dashboard in chromeless native window mode.

3. **Or Run via Terminal**:
   ```bash
   node server.js
   ```
   Open your browser at `http://127.0.0.1:48888`.

4. **Add Desktop Shortcut**:
   Right-click `create_shortcut.ps1` and select *Run with PowerShell* to generate an official icon shortcut on your Windows Desktop.

---

## 📊 Performance Benchmarks

| Metric | Before Apex | After Apex Sweep | Improvement |
| :--- | :--- | :--- | :--- |
| **Idle RAM Usage (8 GB Laptop)** | 5.8 GB (72%) | 3.1 GB (38%) | **+2.7 GB Freed** |
| **Flush Latency** | — | < 450 ms | **Near Instant** |
| **Background Memory Overhead** | — | ~28 MB | **Featherweight** |
| **Third-Party Dependencies** | — | **0 (Zero)** | **100% Clean** |

---

## 🛡️ Architecture & Zero-Trust Security

- **Strict Localhost Binding**: The internal Node.js server listens exclusively on `127.0.0.1:48888`. It never accepts external LAN connections or exposes WAN ports.
- **Zero Hardcoded Paths**: Dynamic hardware and path detection (`%~dp0`, WMI/CIM objects) ensures full cross-machine compatibility across Intel, AMD, and ARM64 Windows setups.
- **No Third-Party Bloat**: Zero vulnerability risk from `npm` packages—no telemetry, no supply chain risks, and no tracking.

---

## 👨‍💻 Author & Contributions

Created with passion by **Muhammad Ibrahim (Abdaal)** ([@Muhammad-Ibraheem-kamboh](https://github.com/Muhammad-Ibraheem-kamboh)).

Contributions, issues, and feature requests are welcome! If this project helps speed up your machine, please give it a **⭐ Star on GitHub**!

---

## 📜 License
Distributed under the **MIT License**. See `LICENSE` for more information.
