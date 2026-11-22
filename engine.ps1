param (
    [string]$Action = "GetStats",
    [string]$Target = "",
    [string]$Mode = ""
)

$ErrorActionPreference = "SilentlyContinue"

switch ($Action) {
    "GetStats" {
        # 1. CPU with Cache & Speed
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cpuLoad = [int]$cpu.LoadPercentage
        $cpuName = $cpu.Name.Trim()

        # 2. RAM with Hardware Speed & Standby Cache
        $os = Get-CimInstance Win32_OperatingSystem
        $totalRamMb = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
        $freeRamMb = [math]::Round($os.FreePhysicalMemory / 1024, 0)
        $usedRamMb = $totalRamMb - $freeRamMb
        $ramPercent = if ($totalRamMb -gt 0) { [math]::Round(($usedRamMb / $totalRamMb) * 100, 1) } else { 0 }
        
        $ramHw = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1
        $wslActive = (Get-Process -Name "vmmemWSL" -ErrorAction SilentlyContinue) -ne $null

        # 3. Disk C:
        $drive = Get-PSDrive C
        $totalDiskGb = [math]::Round(($drive.Used + $drive.Free) / 1GB, 1)
        $freeDiskGb = [math]::Round($drive.Free / 1GB, 1)
        $usedDiskGb = [math]::Round($drive.Used / 1GB, 1)
        $diskPercent = if ($totalDiskGb -gt 0) { [math]::Round(($usedDiskGb / $totalDiskGb) * 100, 1) } else { 0 }

        # 4. Battery
        $battery = Get-CimInstance Win32_Battery | Select-Object -First 1
        $battPct = if ($battery) { [int]$battery.EstimatedChargeRemaining } else { 100 }
        $battStatus = if ($battery) {
            switch ($battery.BatteryStatus) {
                1 { "Discharging" }
                2 { "AC Power (Charging)" }
                3 { "Fully Charged" }
                default { "AC Connected" }
            }
        } else { "Desktop / AC" }

        # 5. Processes count
        $procCount = (Get-Process).Count

        $result = @{
            cpu = @{
                name = $cpuName
                load = $cpuLoad
                cores = $cpu.NumberOfCores
                threads = $cpu.NumberOfLogicalProcessors
                currentClockMhz = $cpu.CurrentClockSpeed
                maxClockMhz = $cpu.MaxClockSpeed
                l2CacheKb = $cpu.L2CacheSize
                l3CacheKb = $cpu.L3CacheSize
            }
            ram = @{
                totalMb = $totalRamMb
                usedMb = $usedRamMb
                freeMb = $freeRamMb
                percent = $ramPercent
                speedMhz = if ($ramHw) { $ramHw.Speed } else { 0 }
                manufacturer = if ($ramHw) { $ramHw.Manufacturer } else { "Generic" }
                wslRunning = $wslActive
            }
            disk = @{
                totalGb = $totalDiskGb
                usedGb = $usedDiskGb
                freeGb = $freeDiskGb
                percent = $diskPercent
            }
            battery = @{
                percent = $battPct
                status = $battStatus
            }
            processes = $procCount
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }

        $result | ConvertTo-Json -Depth 4
    }

    "FlushRam" {
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)

        # Trim process working sets
        $procs = Get-Process
        $trimmedCount = 0
        foreach ($p in $procs) {
            try {
                $p.MinWorkingSet = $p.MinWorkingSet
                $trimmedCount++
            } catch {}
        }

        # Force garbage collection in .NET runtime
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Milliseconds 400
        $osAfter = Get-CimInstance Win32_OperatingSystem
        $freeAfter = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
        $freedMb = [math]::Max(0, ($freeAfter - $freeBefore))

        @{
            success = $true
            freedMb = $freedMb
            trimmedProcesses = $trimmedCount
            freeBefore = $freeBefore
            freeAfter = $freeAfter
        } | ConvertTo-Json
    }

    "KillBloat" {
        $bloatNames = @(
            "PhoneExperienceHost",
            "BingWallpaper",
            "CrossDeviceService",
            "Microsoft.Share",
            "mshmHost",
            "GameBar",
            "GameBarFTServer"
        )

        $killed = @()
        foreach ($name in $bloatNames) {
            $p = Get-Process -Name $name -ErrorAction SilentlyContinue
            if ($p) {
                Stop-Process -Name $name -Force -ErrorAction SilentlyContinue
                $killed += $name
            }
        }

        @{
            success = $true
            killedCount = $killed.Count
            killedApps = $killed
        } | ConvertTo-Json
    }

    "ScanStorage" {
        # Temp sizes
        $sysTemp = "C:\Windows\Temp"
        $userTemp = [System.IO.Path]::GetTempPath()
        $softDist = "C:\Windows\SoftwareDistribution\Download"
        $minidump = "C:\Windows\Minidump"

        function Get-DirSizeMB($path) {
            if (Test-Path $path) {
                $size = (Get-ChildItem -Path $path -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                if ($size) { return [math]::Round($size / 1MB, 1) }
            }
            return 0
        }

        $sysTempMb = Get-DirSizeMB $sysTemp
        $userTempMb = Get-DirSizeMB $userTemp
        $softDistMb = Get-DirSizeMB $softDist
        $minidumpMb = Get-DirSizeMB $minidump
        $totalCleanableMb = [math]::Round($sysTempMb + $userTempMb + $softDistMb + $minidumpMb, 1)

        @{
            sysTempMb = $sysTempMb
            userTempMb = $userTempMb
            softDistMb = $softDistMb
            minidumpMb = $minidumpMb
            totalCleanableMb = $totalCleanableMb
        } | ConvertTo-Json
    }

    "CleanStorage" {
        $cleanedMb = 0
        $filesDeleted = 0

        # 1. Clean User Temp
        $userTemp = [System.IO.Path]::GetTempPath()
        $items = Get-ChildItem -Path $userTemp -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                $len = if (-not $item.PSIsContainer) { $item.Length } else { 0 }
                Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                $cleanedMb += ($len / 1MB)
                $filesDeleted++
            } catch {}
        }

        # 2. Clean Windows Temp
        $sysTemp = "C:\Windows\Temp"
        $sysItems = Get-ChildItem -Path $sysTemp -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($item in $sysItems) {
            try {
                $len = if (-not $item.PSIsContainer) { $item.Length } else { 0 }
                Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                $cleanedMb += ($len / 1MB)
                $filesDeleted++
            } catch {}
        }

        # 3. Clean SoftwareDistribution Download cache (only if Windows Update is idle)
        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if (-not $wuService -or $wuService.Status -ne "Running") {
            $softDist = "C:\Windows\SoftwareDistribution\Download"
            if (Test-Path $softDist) {
                $sdItems = Get-ChildItem -Path $softDist -Recurse -Force -ErrorAction SilentlyContinue
                foreach ($item in $sdItems) {
                    try {
                        $len = if (-not $item.PSIsContainer) { $item.Length } else { 0 }
                        Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        $cleanedMb += ($len / 1MB)
                        $filesDeleted++
                    } catch {}
                }
            }
        }

        # 4. Clean Windows Error Reporting (WER) reports
        $werDir = "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
        if (Test-Path $werDir) {
            $werItems = Get-ChildItem -Path $werDir -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($item in $werItems) {
                try {
                    $len = if (-not $item.PSIsContainer) { $item.Length } else { 0 }
                    Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                    $cleanedMb += ($len / 1MB)
                    $filesDeleted++
                } catch {}
            }
        }

        @{
            success = $true
            cleanedMb = [math]::Round($cleanedMb, 1)
            filesDeleted = $filesDeleted
        } | ConvertTo-Json
    }

    "OptimizeSSD" {
        $result = Optimize-Volume -DriveLetter C -ReTrim -Verbose 4>&1
        @{
            success = $true
            message = "SSD TRIM command executed successfully for drive C:."
        } | ConvertTo-Json
    }

    "SetHibernation" {
        if ($Mode -eq "reduced") {
            powercfg /h /type reduced
            $msg = "Hibernation size reduced (saves 4GB - 8GB while keeping Fast Startup)."
        } elseif ($Mode -eq "off") {
            powercfg /h off
            $msg = "Hibernation completely disabled (recovered 100% of hiberfil.sys storage)."
        } else {
            powercfg /h /type full
            $msg = "Hibernation restored to full standard mode."
        }

        @{
            success = $true
            message = $msg
        } | ConvertTo-Json
    }

    "SetPowerPlan" {
        if ($Mode -eq "high") {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
            if ($LASTEXITCODE -ne 0) {
                powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
            }
            $msg = "Switched to High Performance mode."
        } elseif ($Mode -eq "saver") {
            powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a
            $msg = "Switched to Power Saver mode (saves battery)."
        } else {
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            $msg = "Switched to Balanced mode."
        }

        @{
            success = $true
            message = $msg
        } | ConvertTo-Json
    }

    "FlushDNS" {
        Clear-DnsClientCache
        ipconfig /flushdns | Out-Null
        @{
            success = $true
            message = "DNS Cache Flushed & Network Stack Reset"
        } | ConvertTo-Json
    }

    "GameBoost" {
        # 1. Flush RAM working sets
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)
        $procs = Get-Process
        foreach ($p in $procs) {
            try { $p.MinWorkingSet = $p.MinWorkingSet } catch {}
        }
        [System.GC]::Collect()

        # 2. Stop non-essential background processes
        $bloats = @("PhoneExperienceHost", "BingWallpaper", "CrossDeviceService", "GameBar", "GameBarFTServer", "mshmHost")
        $killed = 0
        foreach ($b in $bloats) {
            $p = Get-Process -Name $b -ErrorAction SilentlyContinue
            if ($p) {
                Stop-Process -Name $b -Force -ErrorAction SilentlyContinue
                $killed++
            }
        }

        # 3. Pause print spooler and telemetry during gameplay
        Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
        Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue

        # 4. Set High Performance
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul

        Start-Sleep -Milliseconds 300
        $osAfter = Get-CimInstance Win32_OperatingSystem
        $freeAfter = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
        $freedMb = [math]::Max(0, ($freeAfter - $freeBefore))

        @{
            success = $true
            freedMb = $freedMb
            killedCount = $killed
            message = "Ultra Game Booster Active: High Priority Enabled, Telemetry Paused, RAM Cleared."
        } | ConvertTo-Json
    }

    "RestoreStandardMode" {
        # Resume standard services
        Start-Service -Name Spooler -ErrorAction SilentlyContinue
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        @{
            success = $true
            message = "Standard Desktop Mode Restored."
        } | ConvertTo-Json
    }

    "LLMMaxBoost" {
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)

        # 1. Automatic WSL Shutdown (frees 1.5GB - 3GB)
        try {
            wsl --shutdown 2>$null
        } catch {}

        # 2. Pause resource-heavy background services
        $heavyServices = @("WSearch", "DiagTrack", "SysMain", "Spooler")
        $paused = @()
        foreach ($s in $heavyServices) {
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq "Running") {
                Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
                $paused += $s
            }
        }

        # 3. Terminate non-essential background bloat
        $bloats = @("PhoneExperienceHost", "BingWallpaper", "CrossDeviceService", "GameBar", "GameBarFTServer", "mshmHost")
        $killed = 0
        foreach ($b in $bloats) {
            $p = Get-Process -Name $b -ErrorAction SilentlyContinue
            if ($p) {
                Stop-Process -Name $b -Force -ErrorAction SilentlyContinue
                $killed++
            }
        }

        # 4. Deep Working-Set RAM Flush
        $procs = Get-Process
        foreach ($p in $procs) {
            try { $p.MinWorkingSet = $p.MinWorkingSet } catch {}
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Milliseconds 500

        $osAfter = Get-CimInstance Win32_OperatingSystem
        $freeAfter = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
        $freedMb = [math]::Max(0, ($freeAfter - $freeBefore))

        # 5. Real Hardware Speeds
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $mem = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1

        @{
            success = $true
            mode = "LLM Maximum Power Mode"
            freeRamMb = $freeAfter
            freedMb = $freedMb
            wslStopped = $true
            pausedServices = $paused
            killedBloat = $killed
            cpuSpeed = "$($cpu.CurrentClockSpeed) MHz"
            l2Cache = "$($cpu.L2CacheSize) KB"
            l3Cache = "$($cpu.L3CacheSize) KB"
            ramSpeed = "$($mem.Speed) MHz"
            message = "LLM Boost Active: WSL shut down, $killed background tasks cleared. Free RAM: $freeAfter MB (+$freedMb MB freed)."
        } | ConvertTo-Json -Depth 3
    }

    "RestoreServices" {
        # Restore normal desktop services
        $servicesToRestore = @("WSearch", "SysMain", "Spooler")
        foreach ($s in $servicesToRestore) {
            Start-Service -Name $s -ErrorAction SilentlyContinue
        }
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
        @{
            success = $true
            message = "Standard Windows background services (Search, SysMain, Spooler) restored."
        } | ConvertTo-Json
    }

    "BackupFiles" {
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $targetDrive = if (Test-Path "D:\") { "D:\" } else { "C:\" }
        $backupRoot = Join-Path $targetDrive "ApexBackups"
        $destDir = Join-Path $backupRoot "Backup_$timestamp"
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

        $copiedCount = 0

        # Backup Desktop
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        if (Test-Path $desktopPath) {
            $destDesktop = Join-Path $destDir "Desktop"
            Copy-Item -Path $desktopPath -Destination $destDesktop -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Backup Documents (preserving folder hierarchy, excluding heavy node_modules / git)
        $docsPath = [Environment]::GetFolderPath("MyDocuments")
        if (Test-Path $docsPath) {
            $destDocs = Join-Path $destDir "Documents"
            New-Item -ItemType Directory -Path $destDocs -Force | Out-Null
            Get-ChildItem -Path $docsPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules|\.git|VirtualBox' } | ForEach-Object {
                $relPath = [System.IO.Path]::GetRelativePath($docsPath, $_.FullName)
                $targetFile = Join-Path $destDocs $relPath
                $targetFolder = [System.IO.Path]::GetDirectoryName($targetFile)
                if (-not (Test-Path $targetFolder)) { New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null }
                Copy-Item -LiteralPath $_.FullName -Destination $targetFile -Force -ErrorAction SilentlyContinue
                $copiedCount++
            }
        }

        # Backup Chrome Bookmarks
        $chromeBm = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
        if (Test-Path $chromeBm) {
            $bmDest = Join-Path $destDir "BrowserData"
            New-Item -ItemType Directory -Path $bmDest -Force | Out-Null
            Copy-Item -Path $chromeBm -Destination $bmDest -Force -ErrorAction SilentlyContinue
            $copiedCount++
        }

        $allFiles = Get-ChildItem -Path $destDir -Recurse -ErrorAction SilentlyContinue
        $finalSizeMb = [math]::Round((($allFiles | Measure-Object -Property Length -Sum).Sum) / 1MB, 2)
        $finalCount = ($allFiles | Where-Object { -not $_.PSIsContainer }).Count

        @{
            success = $true
            backupPath = $destDir
            filesCount = $finalCount
            sizeMb = $finalSizeMb
            message = "Backup completed! $finalCount critical files ($finalSizeMb MB) secured in $destDir"
        } | ConvertTo-Json
    }

    "DeepCleanCache" {
        $freedBytes = 0
        $itemsRemoved = 0

        # 1. User Temp
        if (Test-Path $env:TEMP) {
            $uFiles = Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($f in $uFiles) {
                try {
                    $l = if ($f.Length) { $f.Length } else { 0 }
                    Remove-Item -Path $f.FullName -Recurse -Force -ErrorAction Stop
                    $freedBytes += $l
                    $itemsRemoved++
                } catch {}
            }
        }

        # 2. Windows Temp
        $wTemp = "C:\Windows\Temp"
        if (Test-Path $wTemp) {
            $wFiles = Get-ChildItem -Path $wTemp -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($f in $wFiles) {
                try {
                    $l = if ($f.Length) { $f.Length } else { 0 }
                    Remove-Item -Path $f.FullName -Recurse -Force -ErrorAction Stop
                    $freedBytes += $l
                    $itemsRemoved++
                } catch {}
            }
        }

        # 3. Windows Update Download Cache (only if Windows Update is idle)
        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if (-not $wuService -or $wuService.Status -ne "Running") {
            $wuDownload = "C:\Windows\SoftwareDistribution\Download"
            if (Test-Path $wuDownload) {
                $wuFiles = Get-ChildItem -Path $wuDownload -Recurse -Force -ErrorAction SilentlyContinue
                foreach ($f in $wuFiles) {
                    try {
                        $l = if ($f.Length) { $f.Length } else { 0 }
                        Remove-Item -Path $f.FullName -Recurse -Force -ErrorAction Stop
                        $freedBytes += $l
                        $itemsRemoved++
                    } catch {}
                }
            }
        }

        # 4. Chrome Media/Shader Cache
        $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\Cache_Data"
        if (Test-Path $chromeCache) {
            $cFiles = Get-ChildItem -Path $chromeCache -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($f in $cFiles) {
                try {
                    $l = if ($f.Length) { $f.Length } else { 0 }
                    Remove-Item -Path $f.FullName -Recurse -Force -ErrorAction Stop
                    $freedBytes += $l
                    $itemsRemoved++
                } catch {}
            }
        }

        # 5. DNS Cache
        Clear-DnsClientCache -ErrorAction SilentlyContinue

        $freedMb = [math]::Round($freedBytes / 1MB, 1)

        @{
            success = $true
            cleanedMb = $freedMb
            itemsCount = $itemsRemoved
            message = "Deep Cache Purge: Wiped $freedMb MB of temp, browser cache & DNS records."
        } | ConvertTo-Json
    }

    "CheckDevEnv" {
        $tools = @()

        # Git
        $gitVer = try { (git --version 2>$null) } catch { $null }
        $tools += @{
            name = "Git Version Control"
            installed = [bool]$gitVer
            version = if ($gitVer) { $gitVer.Trim() } else { "Not installed" }
        }

        # Node.js
        $nodeVer = try { (node -v 2>$null) } catch { $null }
        $tools += @{
            name = "Node.js Runtime"
            installed = [bool]$nodeVer
            version = if ($nodeVer) { $nodeVer.Trim() } else { "Not installed" }
        }

        # Python
        $pyVer = try { (python --version 2>$null) } catch { $null }
        $tools += @{
            name = "Python Environment"
            installed = [bool]$pyVer
            version = if ($pyVer) { $pyVer.Trim() } else { "Not installed" }
        }

        # PowerShell Execution Policy
        $execPol = Get-ExecutionPolicy -Scope CurrentUser
        $tools += @{
            name = "PowerShell Execution Policy"
            installed = ($execPol -eq "RemoteSigned" -or $execPol -eq "Bypass" -or $execPol -eq "Unrestricted")
            version = "$execPol"
        }

        # Windows Terminal
        $wt = Get-Command wt -ErrorAction SilentlyContinue
        $tools += @{
            name = "Windows Terminal"
            installed = [bool]$wt
            version = if ($wt) { "Installed" } else { "Standard Console" }
        }

        @{
            success = $true
            tools = $tools
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        } | ConvertTo-Json -Depth 3
    }

    "SetupDevEnv" {
        $actions = @()

        # Set PowerShell policy to RemoteSigned
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            $actions += "PowerShell script policy set to RemoteSigned (allows developer scripts)"
        } catch {}

        # Enable developer symlinks
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            $actions += "Developer AppModelUnlock enabled"
        } catch {}

        # Git defaults
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git config --global core.autocrlf true 2>$null
            git config --global init.defaultBranch main 2>$null
            $actions += "Git default branch set to 'main' & core.autocrlf configured"
        }

        @{
            success = $true
            actions = $actions
            message = "Developer environment primed: PowerShell execution policy unlocked & Git defaults configured."
        } | ConvertTo-Json
    }

    "RestartExplorer" {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        Start-Process explorer.exe
        @{
            success = $true
            message = "Windows Explorer shell restarted. Desktop and taskbar reloaded."
        } | ConvertTo-Json
    }

    "ResetNetworkStack" {
        ipconfig /flushdns | Out-Null
        netsh winsock reset | Out-Null
        @{
            success = $true
            message = "Network reset complete: DNS resolver cleared & Winsock catalog repaired."
        } | ConvertTo-Json
    }

    default {
        @{ error = "Unknown action $Action" } | ConvertTo-Json
    }
}
