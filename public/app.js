// Apex Windows Optimizer Pro - Master Client Engine
const API_BASE = '';

// Comprehensive Bilingual Dictionary (English & Urdu)
const I18N = {
  en: {
    // Navigation
    nav_dashboard: "Dashboard",
    nav_memory: "Memory Engine",
    nav_storage: "Storage Vault",
    nav_network: "Network & Ping",
    nav_gaming: "Game Booster",
    nav_tweaks: "System Tweaks",
    nav_power: "Power & Battery",
    nav_autopilot: "Auto-Pilot",
    nav_utilities: "Desktop Utilities",
    guard_active: "System Guard Active",
    guard_desc: "Auto-RAM & Storage Shield",

    // Header Actions
    btn_refresh: "Refresh",
    btn_quick_flush: "Quick Flush RAM",
    lang_btn: "اردو (Urdu)",

    // Header Titles per Tab
    title_dashboard: "System Dashboard",
    sub_dashboard: "Real-time hardware telemetry and background maintenance",
    title_memory: "Memory Engine",
    sub_memory: "Working-set optimization, cache flushing, and process management",
    title_storage: "Storage Vault",
    sub_storage: "System junk removal, hibernation footprint management, and SSD ReTrim",
    title_network: "Network & Ping Optimizer",
    sub_network: "DNS resolver cache flush and internet latency stabilizer",
    title_gaming: "Game Booster Suite",
    sub_gaming: "High performance priority and non-essential background service suspension",
    title_tweaks: "System Snappiness & Kernel Tweaks",
    sub_tweaks: "Windows reverse-engineered latency reduction and graphics optimization",
    title_power: "Power & Battery Guard",
    sub_power: "Processor clock profiles and safe swell voltage prevention",
    title_autopilot: "Auto-Pilot Rules",
    sub_autopilot: "Autonomous background watchdog and system event logs",
    title_utilities: "Custom Desktop Utilities Suite",
    sub_utilities: "One-click critical backups, deep cache purge, and instant developer environment setup",

    // Utilities Tab
    util_backup_title: "One-Click Critical Backup",
    util_backup_what: "Safely archives your Desktop, Documents, Code projects, and Chrome Bookmarks to a timestamped backup folder.",
    util_backup_why: "Guarantees you never lose valuable work, source code, or browser settings if something goes wrong.",
    btn_start_backup: "💾 Run One-Click Backup",

    util_clean_title: "Deep Cache & Junk Purger",
    util_clean_what: "Wipes Windows Temp, Windows Update download cache, Thumbnail DB, Chrome cache, and DNS cache.",
    util_clean_why: "Reclaims gigabytes of trapped disk space and eliminates mysterious system slowdowns and browser lags.",
    btn_start_clean: "🧹 Deep Purge All Caches",

    util_dev_title: "Developer Environment One-Click Setup",
    util_dev_what: "Checks Git, Node.js, Python, and unlocks PowerShell script execution policies and developer symlink permissions.",
    util_dev_why: "Sets up your laptop as an optimized coding workstation in seconds without confusing manual setups.",
    btn_start_dev: "🚀 Setup Developer Environment",

    util_rescue_title: "Desktop & Network Rescue Tools",
    util_rescue_what: "Instant recovery tools for stuck Windows Explorer shells, frozen taskbars, and dropped network connections.",
    util_rescue_why: "Fixes UI freezes and restores internet access without needing to reboot your computer.",
    btn_restart_exp: "🔄 Restart Windows Explorer",
    btn_reset_net: "🌐 Reset Network & DNS",

    // Dashboard
    hyper_title: "Master Hyper-Boost Mode",
    hyper_desc: "Instantly cleans up trapped RAM, stops background bloat apps, and gives your PC maximum speed in 1 second.",
    btn_hyper: "⚡ ENGAGE HYPER BOOST",
    card_cpu_title: "Processor (CPU)",
    card_ram_title: "Physical Memory (RAM)",
    card_disk_title: "Primary Drive (C:)",
    card_battery_title: "Battery & Power",

    // Brief Labels
    lbl_what: "What it does",
    lbl_why: "Why click",

    // Memory Tab
    mem_trimmer_title: "Working-Set Memory Flush",
    tag_safe: "100% Safe",
    mem_trimmer_what: "Frees up unused memory trapped by background apps without closing any of your open windows.",
    mem_trimmer_why: "Instantly frees 1 to 2 GB of RAM to speed up lagging programs and games.",
    btn_deep_ram: "Flush RAM Across All Processes",

    mem_bloat_title: "Background Bloat Terminator",
    tag_power: "Power Saver",
    mem_bloat_what: "Stops hidden background tasks (Phone Link, Bing Wallpaper, CrossDevice, Copilot hub).",
    mem_bloat_why: "Saves ~300 to 500 MB RAM and prevents CPU wakeups to make your laptop run cooler.",
    btn_kill_bloat: "Terminate Background Bloat",

    llm_title: "LLM & Developer Max Power Mode",
    llm_what: "Shuts down idle WSL virtualization (vmmemWSL), pauses Search/SysMain indexing, and deep-flushes working sets.",
    llm_why: "Reclaims 1.5–3 GB RAM for local AI models, Dockerless builds, compilers, and heavy IDEs.",
    btn_llm_max: "🚀 Engage LLM Max Mode",
    btn_restore_services: "Restore Background Services",

    // Storage Tab
    stor_junk_title: "Cleanable Junk Purger",
    btn_scan: "Scan",
    stor_junk_what: "Clears old Windows Update cache, temp files, and error crash dumps.",
    stor_junk_why: "Reclaims gigabytes of free space on Drive C: without touching your personal files.",
    btn_purge: "Purge System Junk",

    stor_trim_title: "Solid State Drive (SSD) ReTrim",
    tag_ssd: "Hardware TRIM",
    stor_trim_sub: "Wear-leveling optimization for SSD",
    stor_trim_what: "Sends native TRIM commands to the SSD controller to wipe dirty erased blocks.",
    stor_trim_why: "Maintains maximum read/write file speeds and extends SSD hardware lifespan.",
    btn_trim: "Run SSD ReTrim",

    stor_hiber_title: "Hibernation Storage Management (hiberfil.sys)",
    stor_hiber_what: "Windows reserves disk space for hibernation matching your RAM. Reduced mode keeps Fast Startup.",
    stor_hiber_why: "Saves ~50% to 100% of hiberfil.sys SSD space instantly (requires Administrator).",
    btn_hiber_reduced: "Reduced Mode (~50% Smaller)",
    btn_hiber_off: "Disable (100% Freed)",
    btn_hiber_full: "Standard Full Mode",

    // Network Tab
    net_title: "DNS & Network Latency Purge",
    tag_fast_net: "Low Latency",
    net_what: "Flushes corrupted DNS domain cache and resets Windows network socket routing.",
    net_why: "Fixes website loading hang-ups, reduces ping spikes in games, and refreshes connection speed.",
    btn_flush_dns: "Flush DNS & Reset Network Cache",

    // Game Booster Tab
    game_title: "Ultra Gaming Boost Mode",
    tag_max_fps: "Max FPS",
    game_what: "Frees RAM, halts print spooler and telemetry services, and sets High Performance power plan.",
    game_why: "Stops micro-stuttering, stabilizes frame rates, and directs all CPU threads to your game.",
    btn_engage_game: "🎮 ENGAGE GAME BOOST",
    btn_restore_std: "Restore Normal Desktop Mode",

    // System Tweaks Tab (Reverse Engineered)
    tweak_snap_title: "Instant UI Responsiveness (Zero Menu Delay)",
    tag_instant: "Zero Latency",
    tweak_snap_what: "Reduces Windows hardcoded menu delay from 400ms down to 20ms and disables animation transition lag.",
    tweak_snap_why: "Right-click context menus, taskbar popups, and app windows snap open with instant tactile speed.",
    btn_tweak_snap: "⚡ Engage Instant UI Snappiness",
    tweak_tcp_title: "TCP Network Stack Tuning",
    tweak_tcp_what: "Disables legacy heuristics and optimizes TCP window auto-tuning.",
    tweak_tcp_why: "Reduces ping jitter in games and speeds up web download handshakes.",
    btn_tweak_tcp: "Optimize TCP Network Stack",
    tweak_trans_title: "GPU VRAM Transparency Saver",
    tweak_trans_what: "Toggles DWM acrylic blur transparency on taskbar and windows.",
    tweak_trans_why: "Saves ~150 MB of GPU video memory and stops integrated GPU thermal throttling.",
    btn_tweak_trans: "Toggle Transparency Mode",

    // Power Tab
    pwr_title: "Hardware Performance Profiles",
    pwr_what: "Adjusts CPU processor clock throttling and cooling fan behavior for optimal performance.",
    pwr_why: "Choose High Performance for speed, or Balanced/Saver to keep your laptop cool and quiet.",
    btn_pwr_high: "⚡ High Performance (Full Clock Speed)",
    btn_pwr_balanced: "⚖️ Balanced (Intelligent Clock Scaling)",
    btn_pwr_saver: "🔋 Power Saver (Cool & Quiet)",

    bat_title: "Battery Swell Prevention (85% Safe Cap)",
    bat_what: "Warns you with an audible desktop notification when your battery charges to 85%.",
    bat_why: "Stops lithium pouch cell gas buildup so your battery never expands, swells, or degrades.",
    tag_swell_active: "Safe Swell Guard Active",

    // Auto-Pilot
    auto_title: "Autonomous Background Rules",
    tag_active_watchdog: "Watchdog 2m",
    auto_what: "Runs silently in background to automatically clean RAM and storage whenever needed.",
    auto_why: "Zero manual work. Your laptop stays fast 24/7 without opening this app constantly.",
    auto_ram_title: "Auto-Flush RAM at High Load",
    auto_ram_sub: "Trims inactive memory automatically when usage crosses threshold",
    auto_stor_title: "Automated Temp Junk Sweeper",
    auto_stor_sub: "Cleans expired temporary files and update cache every 6 hours",
    auto_bat_title: "85% Battery Safe Cap Alert",
    auto_bat_sub: "Notifies when battery charges to safe ceiling to prevent cell swelling",
    logs_title: "Engine Activity Logs"
  },
  ur: {
    // Navigation
    nav_dashboard: "ڈیش بورڈ",
    nav_memory: "میموری اور ریم",
    nav_storage: "اسٹوریج والٹ",
    nav_network: "نیٹ ورک اور پنگ",
    nav_gaming: "گیم بوسٹر",
    nav_tweaks: "سسٹم ٹویکس",
    nav_power: "پاور اور بیٹری",
    nav_autopilot: "آٹو پائلٹ",
    nav_utilities: "ڈیسک ٹاپ یوٹیلیٹیز",
    guard_active: "سسٹم گارڈ فعال ہے",
    guard_desc: "خودکار ریم اور اسٹوریج شیلڈ",

    // Header Actions
    btn_refresh: "ریفریش",
    btn_quick_flush: "فوری ریم خالی کریں",
    lang_btn: "English (انگریزی)",

    // Header Titles per Tab
    title_dashboard: "سسٹم ڈیش بورڈ",
    sub_dashboard: "ہارڈ ویئر کی لائیو معلومات اور بیک گراؤنڈ مینٹیننس",
    title_memory: "ریم اور میموری انجن",
    sub_memory: "فالتو ریم خالی کریں اور بیک گراؤنڈ پروسیسز روکیں",
    title_storage: "اسٹوریج والٹ",
    sub_storage: "فالتو جنک فائلیں صاف کریں اور ایس ایس ڈی کو تیز رکھیں",
    title_network: "نیٹ ورک اور پنگ آپٹیمائزر",
    sub_network: "انٹرنیٹ کیشے صاف کریں اور گیمز میں پنگ مستحکم کریں",
    title_gaming: "گیم بوسٹر موڈ",
    sub_gaming: "گیمنگ کے لیے زیادہ سے زیادہ ایف پی ایس اور اسپیڈ",
    title_tweaks: "سسٹم اسپیڈ اور کرنل اصلاحات",
    sub_tweaks: "ونڈوز لیٹنسی کا خاتمہ اور گرافکس میموری کی بچت",
    title_power: "پاور اور بیٹری گارڈ",
    sub_power: "پاور پلانز اور 85 فیصد بیٹری حفاظت الرٹ",
    title_autopilot: "آٹو پائلٹ قوانین",
    sub_autopilot: "خودکار بیک گراؤنڈ واچ ڈاگ اور سرگرمی لاگز",
    title_utilities: "ڈیسک ٹاپ یوٹیلیٹیز سوٹ",
    sub_utilities: "ایک کلک بیک اپ، ڈیپ کیشے صفائی اور ڈیولپر سیٹ اپ",

    // Utilities Tab
    util_backup_title: "ون کلک کریٹیکل بیک اپ",
    util_backup_what: "آپ کے ڈیسک ٹاپ، ڈاکیومنٹس اور کروم بُک مارکس کا محفوظ بیک اپ بناتا ہے۔",
    util_backup_why: "اہم کام، کوڈ اور براؤزر سیٹنگز کو کسی بھی مسئلے سے محفوظ رکھتا ہے۔",
    btn_start_backup: "💾 ون کلک بیک اپ چلائیں",

    util_clean_title: "ڈیپ کیشے اور جنک کلینر",
    util_clean_what: "ونڈوز ٹیمپ، اپڈیٹ کیشے، تھمب نیل، کروم کیشے اور ڈی این ایس صاف کرتا ہے۔",
    util_clean_why: "جگہ خالی کرتا ہے اور براؤزر و سسٹم کی سستی کو ختم کرتا ہے۔",
    btn_start_clean: "🧹 تمام کیشے صاف کریں",

    util_dev_title: "ڈیولپر انوائرمنٹ ون کلک سیٹ اپ",
    util_dev_what: "Git، Node.js، Python چیک کرتا ہے اور پاور شیل اسکرپٹ پالیسی فعال کرتا ہے۔",
    util_dev_why: "چند سیکنڈز میں کوڈنگ کے لیے لیپ ٹاپ کو مکمل طور پر تیار کرتا ہے۔",
    btn_start_dev: "🚀 ڈیولپر انوائرمنٹ سیٹ اپ کریں",

    util_rescue_title: "ڈیسک ٹاپ اور نیٹ ورک ریسکیو ٹولز",
    util_rescue_what: "اٹکے ہوئے ونڈوز ایکسپلورر اور خراب نیٹ ورک کنکشن کو فوری بحال کرتا ہے۔",
    util_rescue_why: "کمپیوٹر ری اسٹارٹ کیے بغیر سسٹم اور انٹرنیٹ بحال کرتا ہے۔",
    btn_restart_exp: "🔄 ونڈوز ایکسپلورر ری اسٹارٹ کریں",
    btn_reset_net: "🌐 نیٹ ورک اور ڈی این ایس ری سیٹ کریں",

    // Dashboard
    hyper_title: "ماسٹر ہائپر بوسٹ موڈ",
    hyper_desc: "بغیر کسی ایپ کو بند کیے ریم خالی کرتا ہے، فالتو پراسیسز روکتا ہے اور پی سی کو فوری فل اسپیڈ دیتا ہے۔",
    btn_hyper: "⚡ ہائپر بوسٹ شروع کریں",
    card_cpu_title: "پروسیسر (سی پی یو)",
    card_ram_title: "فزیکل میموری (ریم)",
    card_disk_title: "پرائمری ڈرائیو (C:)",
    card_battery_title: "بیٹری اور چارجنگ",

    // Brief Labels
    lbl_what: "یہ کیا کرتا ہے",
    lbl_why: "فائدہ",

    // Memory Tab
    mem_trimmer_title: "ورکنگ سیٹ ریم فلیش",
    tag_safe: "100٪ محفوظ",
    mem_trimmer_what: "بغیر کسی کھلی ونڈو یا ایپ کو بند کیے، فالتو اور ضائع ہونے والی ریم فوری واپس لے لیتا ہے۔",
    mem_trimmer_why: "لیپ ٹاپ کی 1 سے 2 جی بی ریم فوری خالی ہو کر سست ایپس کو تیز کرتی ہے۔",
    btn_deep_ram: "تمام ایپس کی ریم خالی کریں",

    mem_bloat_title: "بیک گراؤنڈ بلوٹ ٹرمینیٹر",
    tag_power: "بیٹری سیور",
    mem_bloat_what: "خفیہ بیک گراؤنڈ پراسیسز (جیسے فون لنک، بنگ وال پیپر، کو پائلٹ) کو بند کرتا ہے۔",
    mem_bloat_why: "300 سے 500 ایم بی ریم بچاتا ہے اور لیپ ٹاپ کو ٹھنڈا رکھتا ہے۔",
    btn_kill_bloat: "بیک گراؤنڈ بلوٹ بند کریں",

    llm_title: "ایل ایل ایم اور ڈیولپر میکس پاور موڈ",
    llm_what: "غیر ضروری WSL ورچوئلائزیشن بند کرتا ہے، سرچ/SysMain سروسز روکتا ہے اور گہری ریم صفائی کرتا ہے۔",
    llm_why: "لوکل AI ماڈلز اور بھاری IDEs کے لیے 1.5 سے 3 جی بی تک ریم فوری خالی کرتا ہے۔",
    btn_llm_max: "🚀 ایل ایل ایم میکس موڈ فعال کریں",
    btn_restore_services: "بیک گراؤنڈ سروسز بحال کریں",

    // Storage Tab
    stor_junk_title: "فالتو جنک فائل کلینر",
    btn_scan: "اسکین کریں",
    stor_junk_what: "پرانی ونڈوز اپڈیٹ فائلیں، ٹیمپریری کیشے اور کریش ڈمپس صاف کرتا ہے۔",
    stor_junk_why: "آپ کے ضروری ڈیٹا کو چھیڑے بغیر ڈرائیو C میں کئی جی بی خالی جگہ بناتا ہے۔",
    btn_purge: "سسٹم جنک ڈیلیٹ کریں",

    stor_trim_title: "ایس ایس ڈی (SSD) ری ٹرم",
    tag_ssd: "ہارڈ ویئر ٹرم",
    stor_trim_sub: "ایس ایس ڈی کی زندگی اور اسپیڈ بڑھائیں",
    stor_trim_what: "ایس ایس ڈی کے ڈیلیٹ شدہ بلاکس کو صاف کرنے کے لیے نیٹو ٹرم کمانڈ بھیجتا ہے۔",
    stor_trim_why: "فائل کاپی اور گیم لوڈنگ اسپیڈ کو ہمیشہ تیز رکھتا ہے۔",
    btn_trim: "ایس ایس ڈی ری ٹرم چلائیں",

    stor_hiber_title: "ہائبرنیشن سائز کنٹرول (hiberfil.sys)",
    stor_hiber_what: "ونڈوز ریم کے برابر جگہ ہائبرنیشن کے لیے محفوظ رکھتی ہے۔ ریڈیوسڈ موڈ فاسٹ اسٹارٹ اپ کو برقرار رکھتا ہے۔",
    stor_hiber_why: "ایس ایس ڈی کی 50% سے 100% ہائبرنیشن جگہ بچاتا ہے (ایڈمنسٹریٹر درکار)۔",
    btn_hiber_reduced: "ریڈیوسڈ موڈ (~50% بچائیں)",
    btn_hiber_off: "ہائبرنیشن بند کریں (100% خالی)",
    btn_hiber_full: "فل اسٹینڈرڈ موڈ",

    // Network Tab
    net_title: "ڈی این ایس اور نیٹ ورک پنگ فلیش",
    tag_fast_net: "کم پنگ",
    net_what: "انٹرنیٹ ڈی این ایس کیشے صاف کرتا ہے اور ونڈوز ساکٹ روٹنگ کو ری سیٹ کرتا ہے۔",
    net_why: "ویب سائٹس کے اٹکنے اور گیمز میں پنگ ہائی ہونے کے مسائل کو فوری حل کرتا ہے۔",
    btn_flush_dns: "ڈی این ایس صاف کریں",

    // Game Booster Tab
    game_title: "الٹرا گیمنگ بوسٹ موڈ",
    tag_max_fps: "میکس ایف پی ایس",
    game_what: "ریم خالی کرتا ہے، فالتو پرنٹر اور ٹیلی میٹری سروسز کو روک کر ہائی پرفارمنس لگاتا ہے۔",
    game_why: "گیمز میں لیگ اور جھٹکے ختم کرتا ہے اور مستحکم فریم ریٹ فراہم کرتا ہے۔",
    btn_engage_game: "🎮 گیم بوسٹ آن کریں",
    btn_restore_std: "نارمل ڈیسک ٹاپ موڈ بحال کریں",

    // System Tweaks Tab (Reverse Engineered)
    tweak_snap_title: "فوری ونڈوز ریسپانس (زیرو مینو ڈیلے)",
    tag_instant: "زیرو تاخیر",
    tweak_snap_what: "ونڈوز کے 400 ملی سیکنڈ مینو ڈیلے کو کم کر کے 20ms کرتا ہے اور اینیمیشنز کی سستی ختم کرتا ہے۔",
    tweak_snap_why: "رائٹ کلک، اسٹارٹ مینو اور فولڈرز بغیر کسی تاخیر کے پلک جھپکتے کھلتے ہیں۔",
    btn_tweak_snap: "⚡ فوری ونڈوز رسپانس فعال کریں",
    tweak_tcp_title: "ٹی سی پی نیٹ ورک ٹیوننگ",
    tweak_tcp_what: "پرانے نیٹ ورک ہیورسٹکس بند کر کے ٹی سی پی آٹو ٹیوننگ سیٹ کرتا ہے۔",
    tweak_tcp_why: "گیمز میں پنگ اتار چڑھاؤ کو روکتا ہے اور انٹرنیٹ کنکشن مستحکم کرتا ہے۔",
    btn_tweak_tcp: "ٹی سی پی اسٹیک ٹیون کریں",
    tweak_trans_title: "جی پی یو ٹرانسپیرنسی سیور",
    tweak_trans_what: "ٹاسک بار اور ونڈوز کے دھندلے شیشے (Blur) کا اثر آن/آف کرتا ہے۔",
    tweak_trans_why: "جی پی یو ویڈیو میموری (VRAM) بچاتا ہے اور ہیٹنگ کم کرتا ہے۔",
    btn_tweak_trans: "ٹرانسپیرنسی تبدیل کریں",

    // Power Tab
    pwr_title: "ہارڈ ویئر پرفارمنس پروفائلز",
    pwr_what: "سی پی یو پروسیسر کی کلاک اسپیڈ اور کولنگ فین کو ایڈجسٹ کرتا ہے۔",
    pwr_why: "گیمنگ کے لیے ہائی اسپیڈ، یا بیٹری کے لیے کول اور پرسکون موڈ منتخب کریں۔",
    btn_pwr_high: "⚡ ہائی پرفارمنس (فل کلاک اسپیڈ)",
    btn_pwr_balanced: "⚖️ متوازن (بیلنسڈ موڈ)",
    btn_pwr_saver: "🔋 پاور سیور (ٹھنڈا اور بیٹری فرینڈلی)",

    bat_title: "بیٹری حفاظت اور پھولنے سے بچاؤ (85٪ الرٹ)",
    bat_what: "بیٹری 85 فیصد چارج ہونے پر آپ کو الرٹ دیتا ہے تاکہ چارجر نکال سکیں۔",
    bat_why: "لیتھیم بیٹری میں گیس بننے اور اس کے پھولنے کے نقصان سے مکمل محفوظ رکھتا ہے۔",
    tag_swell_active: "بیٹری گارڈ فعال ہے",

    // Auto-Pilot
    auto_title: "خودکار آٹو پائلٹ رولز",
    tag_active_watchdog: "واچ ڈاگ 2 منٹ",
    auto_what: "پس منظر میں خاموشی سے چلتا ہے اور ریم اور اسٹوریج کو خود بخود صاف رکھتا ہے۔",
    auto_why: "کسی دستی کام کی ضرورت نہیں، آپ کا لیپ ٹاپ ہمیشہ تیز رہتا ہے۔",
    auto_ram_title: "ہائی لوڈ پر ریم خودکار خالی کریں",
    auto_ram_sub: "جب ریم ایک حد سے زیادہ استعمال ہو تو فالتو کیشے خود صاف ہو جاتی ہے",
    auto_stor_title: "خودکار روزانہ کیشے صفائی",
    auto_stor_sub: "ہر 6 گھنٹے بعد عارضی جنک فائلیں خود صاف کر دی جاتی ہیں",
    auto_bat_title: "85 فیصد بیٹری محفوظ چارج الرٹ",
    auto_bat_sub: "بیٹری 85 فیصد ہونے پر یاد دہانی دیتا ہے تاکہ بیٹری خراب نہ ہو",
    logs_title: "انجن سرگرمی لاگز"
  }
};

// Current active language
let currentLang = localStorage.getItem('apex_lang') || 'en';
let currentTab = 'dashboard';
let isActionRunning = false;

// -------------------------------------------------------------
// Language Switcher Function
// -------------------------------------------------------------
function setLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('apex_lang', lang);

  // Set HTML direction
  document.documentElement.dir = (lang === 'ur') ? 'rtl' : 'ltr';
  document.documentElement.lang = lang;

  // Toggle button text
  const langBtnText = document.getElementById('lang-btn-text');
  if (langBtnText) {
    langBtnText.textContent = I18N[lang].lang_btn;
  }

  // Update brand sub
  const brandSub = document.getElementById('brand-sub');
  if (brandSub) {
    brandSub.textContent = (lang === 'ur') ? 'ونڈوز آپٹیمائزر' : 'Windows Optimizer';
  }

  // Update all elements with data-i18n
  const elements = document.querySelectorAll('[data-i18n]');
  elements.forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (I18N[lang][key]) {
      el.textContent = I18N[lang][key];
    }
  });

  // Update header title & subtitle
  updateHeaderTitle();
}

function updateHeaderTitle() {
  const pageTitle = document.getElementById('page-title');
  const pageSubtitle = document.getElementById('page-subtitle');
  const dict = I18N[currentLang];

  const titleKey = `title_${currentTab}`;
  const subKey = `sub_${currentTab}`;

  if (pageTitle && dict[titleKey]) pageTitle.textContent = dict[titleKey];
  if (pageSubtitle && dict[subKey]) pageSubtitle.textContent = dict[subKey];
}

// -------------------------------------------------------------
// Toast Notification
// -------------------------------------------------------------
function showToast(message, isError = false) {
  const toast = document.getElementById('toast-message');
  const text = document.getElementById('toast-text');
  
  text.textContent = message;
  toast.style.borderColor = isError ? 'var(--danger)' : 'var(--primary)';
  
  const icon = toast.querySelector('svg');
  if (icon) {
    icon.setAttribute('stroke', isError ? '#EF4444' : '#10B981');
  }

  toast.classList.add('show');
  clearTimeout(toast._timeout);
  toast._timeout = setTimeout(() => {
    toast.classList.remove('show');
  }, 3200);
}

// -------------------------------------------------------------
// Navigation / Tab Switching
// -------------------------------------------------------------
function initNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  const tabContents = document.querySelectorAll('.tab-content');

  navItems.forEach(item => {
    item.addEventListener('click', () => {
      const tabId = item.getAttribute('data-tab');
      if (!tabId) return;

      currentTab = tabId;
      navItems.forEach(n => n.classList.remove('active'));
      tabContents.forEach(t => t.classList.remove('active'));

      item.classList.add('active');
      const targetContent = document.getElementById(`tab-${tabId}`);
      if (targetContent) {
        targetContent.classList.add('active');
      }

      updateHeaderTitle();

      if (tabId === 'autopilot') {
        fetchLogs();
      }

      if (tabId === 'utilities') {
        fetchDevTools();
      }
    });
  });
}

// -------------------------------------------------------------
// Telemetry History Buffers & Smooth SVG Visualizers (Images 1, 2, 3 Style)
// -------------------------------------------------------------
const cpuHistory = [];
const ramHistory = [];

function setGaugeArc(arcId, percent) {
  const arc = document.getElementById(arcId);
  if (!arc) return;
  const clamped = Math.max(0, Math.min(100, Number(percent) || 0));
  // Semicircle arc perimeter: pi * 45 = 141.4px
  const offset = 141.4 - (141.4 * (clamped / 100));
  arc.style.strokeDashoffset = offset.toFixed(1);
}

function renderMiniSparkline(lineId, areaId, pts, width, height) {
  const lineEl = document.getElementById(lineId);
  const areaEl = document.getElementById(areaId);
  if (!lineEl || !pts || pts.length < 2) return;

  const n = pts.length;
  const step = width / (n - 1);
  const padTop = 3;
  const padBottom = 3;
  const usableH = height - padTop - padBottom;

  const coords = pts.map((val, i) => {
    const x = (i * step).toFixed(1);
    const clamped = Math.max(0, Math.min(100, val));
    const y = (height - padBottom - (clamped / 100) * usableH).toFixed(1);
    return `${x},${y}`;
  });

  lineEl.setAttribute('points', coords.join(' '));
  if (areaEl) {
    areaEl.setAttribute('points', `0,${height} ${coords.join(' ')} ${width},${height}`);
  }
}

function renderTelemetryStream(cpuPts, ramPts) {
  const width = 600;
  const height = 130;
  const padTop = 16;
  const padBottom = 16;
  const usableH = height - padTop - padBottom;

  function buildSmoothCurve(pts) {
    if (!pts || pts.length < 2) return { lineD: '', areaPoints: '' };
    const n = pts.length;
    const step = width / (n - 1);

    const points = pts.map((val, i) => {
      const clamped = Math.max(0, Math.min(100, val));
      return {
        x: i * step,
        y: height - padBottom - (clamped / 100) * usableH
      };
    });

    let d = `M ${points[0].x.toFixed(1)} ${points[0].y.toFixed(1)}`;
    for (let i = 1; i < points.length; i++) {
      const p0 = points[i - 1];
      const p1 = points[i];
      const cpx1 = (p0.x + (p1.x - p0.x) * 0.45).toFixed(1);
      const cpy1 = p0.y.toFixed(1);
      const cpx2 = (p1.x - (p1.x - p0.x) * 0.45).toFixed(1);
      const cpy2 = p1.y.toFixed(1);
      d += ` C ${cpx1} ${cpy1}, ${cpx2} ${cpy2}, ${p1.x.toFixed(1)} ${p1.y.toFixed(1)}`;
    }

    const areaPts = `0,${height} ` + points.map(p => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ') + ` ${width},${height}`;
    return { lineD: d, areaPoints: areaPts };
  }

  const cpuPaths = buildSmoothCurve(cpuPts);
  const ramPaths = buildSmoothCurve(ramPts);

  const cpuLine = document.getElementById('stream-cpu-line');
  const cpuArea = document.getElementById('stream-cpu-area');
  if (cpuLine && cpuPaths.lineD) cpuLine.setAttribute('d', cpuPaths.lineD);
  if (cpuArea && cpuPaths.areaPoints) cpuArea.setAttribute('points', cpuPaths.areaPoints);

  const ramLine = document.getElementById('stream-ram-line');
  const ramArea = document.getElementById('stream-ram-area');
  if (ramLine && ramPaths.lineD) ramLine.setAttribute('d', ramPaths.lineD);
  if (ramArea && ramPaths.areaPoints) ramArea.setAttribute('points', ramPaths.areaPoints);
}

// -------------------------------------------------------------
// Telemetry & Stats Fetcher
// -------------------------------------------------------------
async function updateStats() {
  try {
    const res = await fetch(`${API_BASE}/api/stats`);
    if (!res.ok) throw new Error('Failed to retrieve telemetry');
    const data = await res.json();

    // 1. CPU
    if (data.cpu) {
      const loadVal = data.cpu.load !== undefined ? data.cpu.load : 0;
      const cpuLoadEl = document.getElementById('cpu-load');
      if (cpuLoadEl) cpuLoadEl.textContent = `${loadVal}%`;
      setGaugeArc('cpu-gauge-arc', loadVal);

      const cpuBar = document.getElementById('cpu-bar');
      if (cpuBar) {
        cpuBar.style.width = `${loadVal}%`;
        if (loadVal > 80) cpuBar.style.background = 'var(--danger)';
        else if (loadVal > 50) cpuBar.style.background = 'var(--warning)';
        else cpuBar.style.background = 'var(--primary)';
      }

      if (data.cpu.name) {
        const cpuNameEl = document.getElementById('cpu-name');
        if (cpuNameEl) cpuNameEl.textContent = data.cpu.name;
      }
      const coresStr = (currentLang === 'ur') ? 'کورز' : 'Cores';
      const threadsStr = (currentLang === 'ur') ? 'تھریڈز' : 'Threads';
      const cpuDetEl = document.getElementById('cpu-details');
      if (cpuDetEl) {
        const clockStr = data.cpu.currentClockMhz ? `${data.cpu.currentClockMhz} MHz` : '-- MHz';
        const cacheStr = data.cpu.l3CacheKb ? ` • L3: ${data.cpu.l3CacheKb} KB` : '';
        cpuDetEl.textContent = `${data.cpu.cores} ${coresStr} / ${data.cpu.threads} ${threadsStr} • ${clockStr}${cacheStr}`;
      }

      // Live Graphical Cache & Clock Meters
      const liveClockEl = document.getElementById('cpu-live-clock');
      const clockBarEl = document.getElementById('cpu-clock-bar');
      if (liveClockEl && data.cpu.currentClockMhz) {
        const maxClk = data.cpu.maxClockMhz || data.cpu.currentClockMhz;
        liveClockEl.textContent = `${data.cpu.currentClockMhz} MHz / ${maxClk} MHz`;
        if (clockBarEl && maxClk > 0) {
          const pct = Math.min(100, Math.round((data.cpu.currentClockMhz / maxClk) * 100));
          clockBarEl.style.width = `${pct}%`;
        }
      }
      const l2ValEl = document.getElementById('cpu-l2-val');
      if (l2ValEl && data.cpu.l2CacheKb) l2ValEl.textContent = `${data.cpu.l2CacheKb} KB`;
      const l3ValEl = document.getElementById('cpu-l3-val');
      if (l3ValEl && data.cpu.l3CacheKb) l3ValEl.textContent = `${data.cpu.l3CacheKb} KB (${(data.cpu.l3CacheKb / 1024).toFixed(1).replace(/\.0$/, '')} MB)`;

      if (cpuHistory.length === 0) cpuHistory.push(Number(loadVal));
      cpuHistory.push(Number(loadVal));
      if (cpuHistory.length > 16) cpuHistory.shift();
      renderMiniSparkline('cpu-sparkline-line', 'cpu-sparkline-area', cpuHistory, 200, 32);
    }

    // 2. RAM
    if (data.ram) {
      const ramPctEl = document.getElementById('ram-percent');
      if (ramPctEl) ramPctEl.textContent = `${data.ram.percent}%`;
      setGaugeArc('ram-gauge-arc', data.ram.percent);

      const ramUsedEl = document.getElementById('ram-used-mb');
      if (ramUsedEl) {
        ramUsedEl.textContent = `${data.ram.usedMb.toLocaleString()} / ${data.ram.totalMb.toLocaleString()} MB`;
      }
      const freePct = (100 - data.ram.percent).toFixed(1);
      const freeLbl = (currentLang === 'ur') ? 'دستیاب میموری:' : 'Free Memory:';
      const ramFreeEl = document.getElementById('ram-free-subtext');
      if (ramFreeEl) {
        const spdStr = data.ram.speedMhz ? ` • ${data.ram.speedMhz} MHz` : '';
        ramFreeEl.textContent = `${freeLbl} ${data.ram.freeMb.toLocaleString()} MB (${freePct}%)${spdStr}`;
      }

      const wslBadge = document.getElementById('wsl-status-badge');
      if (wslBadge) {
        wslBadge.textContent = data.ram.wslRunning ? 'WSL: Running' : 'WSL: Idle';
        wslBadge.style.background = data.ram.wslRunning ? '#FEF3C7' : 'var(--success-bg)';
        wslBadge.style.color = data.ram.wslRunning ? '#B45309' : 'var(--success)';
      }

      if (ramHistory.length === 0) ramHistory.push(Number(data.ram.percent));
      ramHistory.push(Number(data.ram.percent));
      if (ramHistory.length > 16) ramHistory.shift();
      renderMiniSparkline('ram-sparkline-line', 'ram-sparkline-area', ramHistory, 200, 32);
    }

    // 3. Disk (C:)
    if (data.disk) {
      const diskPctEl = document.getElementById('disk-percent');
      if (diskPctEl) diskPctEl.textContent = `${data.disk.percent}%`;
      setGaugeArc('disk-gauge-arc', data.disk.percent);

      const freeStr = (currentLang === 'ur') ? 'جی بی خالی' : 'GB Free';
      const diskFreeEl = document.getElementById('disk-free-gb');
      if (diskFreeEl) diskFreeEl.textContent = `${data.disk.freeGb} ${freeStr}`;
      const diskBar = document.getElementById('disk-bar');
      if (diskBar) diskBar.style.width = `${data.disk.percent}%`;
      const totalLbl = (currentLang === 'ur') ? 'کل:' : 'Total:';
      const mediaLbl = data.disk.mediaType || 'Drive';
      const diskDetEl = document.getElementById('disk-details');
      if (diskDetEl) {
        diskDetEl.textContent = `${totalLbl} ${data.disk.totalGb} GB • Free: ${data.disk.freeGb} GB (${mediaLbl})`;
      }
    }

    // 4. Battery
    if (data.battery) {
      const bPct = data.battery.percent !== undefined ? data.battery.percent : 100;
      const battPctEl = document.getElementById('battery-percent');
      if (battPctEl) battPctEl.textContent = `${bPct}%`;
      setGaugeArc('battery-gauge-arc', bPct);

      const bBar = document.getElementById('battery-bar');
      if (bBar) bBar.style.width = `${bPct}%`;
      const statusBadge = document.getElementById('battery-status');
      const isCharging = data.battery.status.toLowerCase().includes('charging') && !data.battery.status.toLowerCase().includes('dis');
      if (statusBadge) {
        if (data.battery.present === false) {
          statusBadge.textContent = currentLang === 'ur' ? '🔌 ڈیسک ٹاپ / اے سی' : '🔌 Desktop / AC';
        } else {
          statusBadge.textContent = isCharging ? (currentLang === 'ur' ? '⚡ چارج ہو رہا ہے' : '⚡ Charging') : (currentLang === 'ur' ? '🔋 بیٹری پر' : '🔋 On Battery');
        }
      }

      const battSub = document.getElementById('battery-health-subtext');
      if (battSub) {
        if (data.battery.present === false) {
          battSub.textContent = currentLang === 'ur' ? 'براہ راست اے سی پاور پر چل رہا ہے' : 'Running on direct AC power';
          battSub.style.color = 'var(--text-muted)';
        } else if (bPct >= 85 && isCharging) {
          battSub.textContent = (currentLang === 'ur') ? '⚠️ 85٪ محفوظ حد مکمل: بیٹری کی حفاظت کے لیے چارجر نکال دیں۔' : '⚠️ Safe 85% Limit Reached: Unplug to protect battery health.';
          battSub.style.color = 'var(--warning)';
        } else {
          battSub.textContent = (currentLang === 'ur') ? 'سیف بیٹری گارڈ: فعال (85٪ الرٹ)' : 'Safe Swell Guard: Active (85% Limit Alert)';
          battSub.style.color = 'var(--text-muted)';
        }
      }
    }

    // 5. GPU, Active Power Plan & Tweaks State
    const gpuBadge = document.getElementById('gpu-badge');
    if (gpuBadge && data.gpu && data.gpu.name) {
      gpuBadge.textContent = data.gpu.name.replace(/\(R\)|\(TM\)/g, '').trim();
    }

    if (data.power && data.power.activePlan && window.updatePowerButtonStyles) {
      window.updatePowerButtonStyles(data.power.activePlan);
    }

    // 6. Dual Telemetry Wave Stream Card
    const lCpu = document.getElementById('legend-cpu-val');
    if (lCpu && data.cpu) lCpu.textContent = `${data.cpu.load}%`;
    const lRam = document.getElementById('legend-ram-val');
    if (lRam && data.ram) lRam.textContent = `${data.ram.percent}%`;
    const lTasks = document.getElementById('legend-tasks-val');
    if (lTasks && data.processes !== undefined) lTasks.textContent = `${data.processes}`;

    renderTelemetryStream(cpuHistory, ramHistory);

  } catch (err) {
    console.warn('Telemetry update error:', err);
  }
}

// -------------------------------------------------------------
// Logs & Activity
// -------------------------------------------------------------
async function fetchLogs() {
  try {
    const res = await fetch(`${API_BASE}/api/autopilot/logs`);
    if (!res.ok) return;
    const data = await res.json();
    const container = document.getElementById('log-container');
    if (data.logs && data.logs.length > 0) {
      container.innerHTML = data.logs.map(l => `<div class="log-entry">${escapeHtml(l)}</div>`).join('');
    }
  } catch (err) {
    console.warn('Logs fetch failed:', err);
  }
}

function escapeHtml(str) {
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// -------------------------------------------------------------
// Action Handlers
// -------------------------------------------------------------
async function performPost(endpoint, body = {}, successMsg = '') {
  if (isActionRunning) return;
  isActionRunning = true;

  try {
    const res = await fetch(`${API_BASE}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    const result = await res.json();
    if (!res.ok || result.success === false) {
      throw new Error(result.message || result.error || 'Operation failed');
    }

    const message = successMsg || result.message || 'Operation executed successfully';
    showToast(message);
    await updateStats();
    await fetchLogs();
    return result;
  } catch (err) {
    showToast(err.message, true);
    await fetchLogs();
    return null;
  } finally {
    isActionRunning = false;
  }
}

async function scanStorage(silent = false) {
  const btnScan = document.getElementById('btn-scan-storage');
  if (btnScan) {
    btnScan.textContent = (currentLang === 'ur') ? 'اسکیننگ...' : 'Scanning...';
    btnScan.disabled = true;
  }
  try {
    const res = await fetch(`${API_BASE}/api/storage/scan`);
    const data = await res.json();
    if (data && data.totalCleanableMb !== undefined) {
      document.getElementById('cleanable-total').textContent = `${data.totalCleanableMb} MB`;
      const tempTotal = ((data.userTempMb || 0) + (data.sysTempMb || 0)).toFixed(1);
      document.getElementById('cleanable-details').textContent =
        `SoftwareDist: ${data.softDistMb || 0}MB • Temp: ${tempTotal}MB • Dumps: ${data.minidumpMb || 0}MB`;
      if (!silent) {
        const msg = (currentLang === 'ur') ?
          `اسکین مکمل: ${data.totalCleanableMb} ایم بی فالتو فائلیں پائی گئیں` :
          `Scan Complete: Found ${data.totalCleanableMb} MB cleanable junk`;
        showToast(msg);
      }
    }
  } catch (err) {
    if (!silent) showToast('Storage scan error: ' + err.message, true);
  } finally {
    if (btnScan) {
      btnScan.textContent = (currentLang === 'ur') ? 'اسکین کریں' : 'Scan';
      btnScan.disabled = false;
    }
  }
}

async function loadAutoPilotConfig() {
  try {
    const res = await fetch(`${API_BASE}/api/autopilot`);
    if (!res.ok) return;
    const cfg = await res.json();
    const checkAutoRam = document.getElementById('check-auto-ram');
    const checkAutoStorage = document.getElementById('check-auto-storage');
    const checkAutoBattery = document.getElementById('check-auto-battery');
    const sliderRamThresh = document.getElementById('slider-ram-thresh');
    const valRamThresh = document.getElementById('val-ram-thresh');

    if (checkAutoRam && typeof cfg.autoRam === 'boolean') checkAutoRam.checked = cfg.autoRam;
    if (checkAutoStorage && typeof cfg.autoCleanStorage === 'boolean') checkAutoStorage.checked = cfg.autoCleanStorage;
    if (checkAutoBattery && typeof cfg.batteryCapAlarm === 'boolean') checkAutoBattery.checked = cfg.batteryCapAlarm;
    if (sliderRamThresh && cfg.ramThreshold !== undefined) {
      sliderRamThresh.value = cfg.ramThreshold;
      if (valRamThresh) valRamThresh.textContent = `${cfg.ramThreshold}%`;
    }
  } catch (err) {
    console.warn('Auto-Pilot config sync error:', err);
  }
}

// -------------------------------------------------------------
// Wire Event Listeners
// -------------------------------------------------------------
function initActions() {
  // Window Control Dots (Close / Minimize / Maximize)
  const dotClose = document.querySelector('.dot-red');
  const dotMin = document.querySelector('.dot-yellow');
  const dotMax = document.querySelector('.dot-green');
  if (dotClose) {
    dotClose.addEventListener('click', async () => {
      window.close();
      await fetch(`${API_BASE}/api/window/control`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'close' })
      }).catch(() => {});
    });
  }
  if (dotMin) {
    dotMin.addEventListener('click', () => {
      fetch(`${API_BASE}/api/window/control`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'minimize' })
      }).catch(() => {});
    });
  }
  if (dotMax) {
    dotMax.addEventListener('click', () => {
      fetch(`${API_BASE}/api/window/control`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'maximize' })
      }).catch(() => {});
    });
  }

  // Language Switcher Toggle
  document.getElementById('btn-lang-toggle').addEventListener('click', () => {
    const nextLang = (currentLang === 'en') ? 'ur' : 'en';
    setLanguage(nextLang);
    showToast((nextLang === 'ur') ? 'اردو زبان منتخب کی گئی ہے' : 'Switched to English');
  });

  // Refresh button
  document.getElementById('btn-refresh').addEventListener('click', async () => {
    const btn = document.getElementById('btn-refresh');
    btn.style.opacity = '0.6';
    await updateStats();
    btn.style.opacity = '1';
    showToast((currentLang === 'ur') ? 'تازہ ترین ڈیٹا موصول ہو گیا' : 'Telemetry refreshed');
  });

  // Quick Flush RAM
  document.getElementById('btn-quick-flush').addEventListener('click', async () => {
    const res = await performPost('/api/ram/flush');
    if (res && res.freedMb !== undefined) {
      const msg = (currentLang === 'ur') ? 
        `ریم فلیش مکمل: ${res.freedMb} ایم بی ریم خالی کر دی گئی` : 
        `RAM Cleared: Recovered ${res.freedMb} MB back to physical memory`;
      showToast(msg);
    }
  });

  // Deep Working-Set Flush
  document.getElementById('btn-deep-ram-flush').addEventListener('click', async () => {
    const res = await performPost('/api/ram/flush');
    if (res && res.freedMb !== undefined) {
      const msg = (currentLang === 'ur') ? 
        `تمام ایپس کی ریم خالی کر دی گئی: ${res.freedMb} MB بحال` : 
        `Deep Working-Set Trim: Freed ${res.freedMb} MB RAM across all processes`;
      showToast(msg);
    }
  });

  // Bloat Terminator
  document.getElementById('btn-kill-bloat').addEventListener('click', async () => {
    const res = await performPost('/api/ram/kill-bloat');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        `بلوٹ بند: ${res.killedCount} فالتو بیک گراؤنڈ پروسیسز روک دیے گئے` : 
        `Bloat Purge Complete: Stopped ${res.killedCount} idle background processes`;
      showToast(msg);
    }
  });

  // LLM & Developer Max Power Mode
  const btnLlmMax = document.getElementById('btn-llm-max');
  if (btnLlmMax) {
    btnLlmMax.addEventListener('click', async () => {
      const orig = btnLlmMax.textContent;
      btnLlmMax.disabled = true;
      btnLlmMax.style.opacity = '0.7';
      try {
        await performPost('/api/boost/llm-max');
      } finally {
        btnLlmMax.disabled = false;
        btnLlmMax.style.opacity = '1';
        btnLlmMax.textContent = orig;
      }
    });
  }

  const btnRestoreSvc = document.getElementById('btn-restore-services');
  if (btnRestoreSvc) {
    btnRestoreSvc.addEventListener('click', async () => {
      await performPost('/api/boost/restore-services');
    });
  }

  // Master Hyper Boost
  const btnHyper = document.getElementById('btn-master-boost');
  btnHyper.addEventListener('click', async () => {
    const originalText = btnHyper.innerHTML;
    btnHyper.innerHTML = (currentLang === 'ur') ? '⚡ ہائپر بوسٹ چل رہا ہے...' : '⚡ ENGAGING HYPER BOOST...';
    btnHyper.style.opacity = '0.7';

    try {
      const res = await performPost('/api/boost/hyper');
      if (res) {
        const msg = (currentLang === 'ur') ? 
          `ہائپر بوسٹ فعال: ${res.freedMb} MB ریم خالی اور ${res.killedCount} بلوٹ ایپس بند!` : 
          `Hyper-Boost Active: Recovered ${res.freedMb} MB RAM & halted ${res.killedCount} bloat tasks!`;
        showToast(msg);
      }
    } finally {
      btnHyper.innerHTML = originalText;
      btnHyper.style.opacity = '1';
    }
  });

  // DNS Resolver Flush (NEW!)
  document.getElementById('btn-flush-dns').addEventListener('click', async () => {
    const res = await performPost('/api/net/flush-dns');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        'ڈی این ایس کیشے صاف اور نیٹ ورک ساکٹس ری سیٹ ہو گئے' : 
        'DNS Resolver Cache Flushed & Network Stack Reset';
      showToast(msg);
    }
  });

  // Ultra Game Boost (NEW!)
  document.getElementById('btn-game-boost').addEventListener('click', async () => {
    const res = await performPost('/api/boost/game-mode');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        `گیم بوسٹ موڈ آن: ${res.freedMb} MB ریم خالی اور ہائی پرفارمنس لاگو!` : 
        `Ultra Game Boost Active: Recovered ${res.freedMb} MB RAM, High Performance set!`;
      showToast(msg);
    }
  });

  // Restore Standard Desktop Mode (NEW!)
  document.getElementById('btn-standard-mode').addEventListener('click', async () => {
    const res = await performPost('/api/boost/standard-mode');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        'اسٹینڈرڈ ڈیسک ٹاپ موڈ بحال کر دیا گیا' : 
        'Standard Desktop Mode Restored';
      showToast(msg);
    }
  });

  // Snappiness Tweak (NEW!)
  const btnSnap = document.getElementById('btn-tweak-snappiness');
  if (btnSnap) {
    btnSnap.addEventListener('click', async () => {
      const res = await performPost('/api/tweaks/snappiness');
      if (res) {
        showToast((currentLang === 'ur') ? 'فوری ونڈوز رسپانس فعال: مینو ڈیلے ختم ہو گیا' : 'Instant UI Snappiness Active: Menu delay set to 20ms');
      }
    });
  }

  // TCP Tweak (NEW!)
  const btnTcp = document.getElementById('btn-tweak-tcp');
  if (btnTcp) {
    btnTcp.addEventListener('click', async () => {
      const res = await performPost('/api/tweaks/tcp');
      if (res) {
        showToast((currentLang === 'ur') ? 'ٹی سی پی اسٹیک آپٹیمائز ہو گیا' : 'TCP Network Stack Tuned: Heuristics disabled');
      }
    });
  }

  // Transparency Tweak (NEW!)
  const btnTrans = document.getElementById('btn-tweak-transparency');
  if (btnTrans) {
    btnTrans.addEventListener('click', async () => {
      const res = await performPost('/api/tweaks/transparency');
      if (res) {
        showToast(res.message);
      }
    });
  }

  // Storage Scan
  const btnScan = document.getElementById('btn-scan-storage');
  btnScan.addEventListener('click', () => scanStorage(false));

  // Storage Purge
  document.getElementById('btn-purge-storage').addEventListener('click', async () => {
    const res = await performPost('/api/storage/clean');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        `اسٹوریج صفائی مکمل: ${res.cleanedMb} MB فالتو فائلیں ڈیلیٹ ہو گئیں` : 
        `Storage Cleaned: Purged ${res.cleanedMb} MB redundant files`;
      showToast(msg);
      document.getElementById('cleanable-total').textContent = '0 MB';
    }
  });

  // SSD ReTrim
  document.getElementById('btn-trim-ssd').addEventListener('click', async () => {
    const res = await performPost('/api/storage/trim');
    if (res) {
      const msg = (currentLang === 'ur') ? 
        'ایس ایس ڈی ری ٹرم کمانڈ مکمل: ڈرائیو کی کارکردگی اور زندگی بحال' : 
        'SSD ReTrim: Command executed. NAND wear leveled and performance primed.';
      showToast(msg);
    }
  });

  // Hibernation modes
  document.getElementById('btn-hiber-reduced').addEventListener('click', () => {
    performPost('/api/storage/hibernation', { mode: 'reduced' });
  });

  document.getElementById('btn-hiber-off').addEventListener('click', () => {
    performPost('/api/storage/hibernation', { mode: 'off' });
  });

  document.getElementById('btn-hiber-full').addEventListener('click', () => {
    performPost('/api/storage/hibernation', { mode: 'full' });
  });

  // Power Plans
  const powerButtons = {
    high: document.getElementById('btn-plan-high'),
    balanced: document.getElementById('btn-plan-balanced'),
    saver: document.getElementById('btn-plan-saver')
  };

  function updatePowerButtonStyles(activeKey) {
    Object.keys(powerButtons).forEach(key => {
      if (!powerButtons[key]) return;
      if (key === activeKey) {
        powerButtons[key].classList.remove('btn-secondary');
        powerButtons[key].classList.add('btn-primary');
      } else {
        powerButtons[key].classList.remove('btn-primary');
        powerButtons[key].classList.add('btn-secondary');
      }
    });
  }
  window.updatePowerButtonStyles = updatePowerButtonStyles;

  powerButtons.high.addEventListener('click', async () => {
    const res = await performPost('/api/power/plan', { plan: 'high' });
    if (res && res.success !== false) updatePowerButtonStyles('high');
  });

  powerButtons.balanced.addEventListener('click', async () => {
    const res = await performPost('/api/power/plan', { plan: 'balanced' });
    if (res && res.success !== false) updatePowerButtonStyles('balanced');
  });

  powerButtons.saver.addEventListener('click', async () => {
    const res = await performPost('/api/power/plan', { plan: 'saver' });
    if (res && res.success !== false) updatePowerButtonStyles('saver');
  });

  // Auto-Pilot Checkboxes & Slider
  const checkAutoRam = document.getElementById('check-auto-ram');
  const checkAutoStorage = document.getElementById('check-auto-storage');
  const checkAutoBattery = document.getElementById('check-auto-battery');
  const sliderRamThresh = document.getElementById('slider-ram-thresh');
  const valRamThresh = document.getElementById('val-ram-thresh');

  sliderRamThresh.addEventListener('input', () => {
    valRamThresh.textContent = `${sliderRamThresh.value}%`;
  });

  sliderRamThresh.addEventListener('change', syncAutoPilotConfig);

  async function syncAutoPilotConfig() {
    await fetch(`${API_BASE}/api/autopilot`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        autoRam: checkAutoRam.checked,
        ramThreshold: parseInt(sliderRamThresh.value, 10),
        autoCleanStorage: checkAutoStorage.checked,
        batteryCapAlarm: checkAutoBattery.checked
      })
    });
    showToast((currentLang === 'ur') ? 'آٹو پائلٹ ترتیبات محفوظ ہو گئیں' : 'Auto-Pilot settings saved');
    fetchLogs();
  }

  checkAutoRam.addEventListener('change', syncAutoPilotConfig);
  checkAutoStorage.addEventListener('change', syncAutoPilotConfig);
  checkAutoBattery.addEventListener('change', syncAutoPilotConfig);

  // Refresh logs button
  document.getElementById('btn-refresh-logs').addEventListener('click', () => {
    fetchLogs();
    showToast((currentLang === 'ur') ? 'لاگز اپڈیٹ ہو گئے' : 'Logs updated');
  });

    // -----------------------------------------------------------
    // Desktop Utilities Handlers (Shared Helper)
    // -----------------------------------------------------------
    async function runUtilityButton(btn, pendingMsg, endpoint, onSuccess) {
      if (btn) {
        btn.disabled = true;
        btn.style.opacity = '0.6';
      }
      if (pendingMsg) showToast(pendingMsg);
      try {
        const res = await performPost(endpoint);
        if (res && onSuccess) await onSuccess(res);
      } finally {
        if (btn) {
          btn.disabled = false;
          btn.style.opacity = '1';
        }
      }
    }

    const btnBackup = document.getElementById('btn-run-backup');
    if (btnBackup) {
      btnBackup.addEventListener('click', () => {
        runUtilityButton(btnBackup, 'Creating critical backup snapshot...', '/api/utilities/backup', (data) => {
          const st = document.getElementById('backup-status-text');
          if (st) {
            st.textContent = `${data.filesCount} files (${data.sizeMb} MB) secured`;
            st.style.color = 'var(--success)';
          }
          const hint = document.getElementById('backup-target-hint');
          if (hint && data.backupPath) hint.textContent = data.backupPath;
        });
      });
    }

    const btnClean = document.getElementById('btn-run-deep-clean');
    if (btnClean) {
      btnClean.addEventListener('click', () => {
        runUtilityButton(btnClean, 'Purging temp, browser cache & DNS...', '/api/utilities/deep-clean', (data) => {
          const last = document.getElementById('cache-last-cleaned');
          if (last) {
            last.textContent = `Cleaned ${data.cleanedMb} MB (${new Date().toLocaleTimeString()})`;
            last.style.color = 'var(--success)';
          }
        });
      });
    }

    const btnScanDev = document.getElementById('btn-check-dev-env');
    if (btnScanDev) {
      btnScanDev.addEventListener('click', async () => {
        showToast('Scanning developer tools...');
        await fetchDevTools();
        showToast('Dev tools audit updated.');
      });
    }

    const btnSetupDev = document.getElementById('btn-run-dev-setup');
    if (btnSetupDev) {
      btnSetupDev.addEventListener('click', () => {
        runUtilityButton(btnSetupDev, 'Configuring developer environment...', '/api/utilities/dev-setup', () => fetchDevTools());
      });
    }

    const btnRestartExp = document.getElementById('btn-run-restart-explorer');
    if (btnRestartExp) {
      btnRestartExp.addEventListener('click', () => {
        runUtilityButton(btnRestartExp, 'Restarting Windows Explorer...', '/api/utilities/restart-explorer');
      });
    }

    const btnResetNet = document.getElementById('btn-run-reset-network');
    if (btnResetNet) {
      btnResetNet.addEventListener('click', () => {
        runUtilityButton(btnResetNet, 'Flushing DNS and checking Winsock...', '/api/utilities/reset-network');
      });
    }
  }

  async function fetchDevTools() {
    try {
      const res = await fetch(`${API_BASE}/api/utilities/dev-check`);
      if (!res.ok) return;
      const data = await res.json();
      if (!data.tools) return;

      data.tools.forEach(tool => {
        if (tool.name.includes('Git')) {
          const el = document.getElementById('dev-git-status');
          if (el) {
            el.textContent = tool.version;
            el.style.color = tool.installed ? 'var(--success)' : 'var(--danger)';
          }
        }
        if (tool.name.includes('Node')) {
          const el = document.getElementById('dev-node-status');
          if (el) {
            el.textContent = tool.version;
            el.style.color = tool.installed ? 'var(--success)' : 'var(--danger)';
          }
        }
        if (tool.name.includes('Python')) {
          const el = document.getElementById('dev-python-status');
          if (el) {
            el.textContent = tool.version;
            el.style.color = tool.installed ? 'var(--success)' : 'var(--text-muted)';
          }
        }
        if (tool.name.includes('PowerShell')) {
          const el = document.getElementById('dev-ps-status');
          if (el) {
            el.textContent = tool.version;
            el.style.color = tool.installed ? 'var(--success)' : 'var(--warning)';
          }
        }
      });
    } catch (e) {
      console.error(e);
    }
  }

// -------------------------------------------------------------
// App Initialization
// -------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initActions();
  setLanguage(currentLang);
  loadAutoPilotConfig();
  updateStats();
  fetchLogs();

  // Telemetry loop every 2.5 seconds
  setInterval(updateStats, 2500);

  // Silent initial storage scan (no intrusive toast on launch)
  setTimeout(() => scanStorage(true), 1000);
});
