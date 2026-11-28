param (
    [string]$Action = "GetStats",
    [string]$Target = "",
    [string]$Mode = ""
)

$ErrorActionPreference = "SilentlyContinue"

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-DirectoryContents {
    param(
        [string]$Path,
        [string]$Filter = "*"
    )
    $bytesFreed = [double]0
    $countDeleted = 0
    if (-not (Test-Path -LiteralPath $Path)) {
        return @{ bytes = 0; count = 0 }
    }
    $items = Get-ChildItem -LiteralPath $Path -Filter $Filter -Recurse -Force -ErrorAction SilentlyContinue |
             Sort-Object { $_.FullName.Length } -Descending
    foreach ($item in $items) {
        try {
            $len = if (-not $item.PSIsContainer) { [double]$item.Length } else { [double]0 }
            Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction Stop
            if (-not $item.PSIsContainer) {
                $bytesFreed += $len
                $countDeleted++
            }
        } catch {}
    }
    return @{ bytes = $bytesFreed; count = $countDeleted }
}

switch ($Action) {
    "GetStaticInfo" {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $ramHw = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
        $diskHw = Get-PhysicalDisk | Select-Object -First 1
        $osInfo = Get-CimInstance Win32_OperatingSystem

        $mediaType = if ($diskHw -and $diskHw.MediaType -and $diskHw.MediaType -ne "Unspecified") {
            $diskHw.MediaType
        } else { "Disk" }

        $result = @{
            isAdmin = (Test-IsAdmin)
            osCaption = if ($osInfo) { $osInfo.Caption.Trim() } else { "Windows" }
            cpu = @{
                name = if ($cpu) { $cpu.Name.Trim() } else { "Processor" }
                cores = if ($cpu) { [int]$cpu.NumberOfCores } else { 0 }
                threads = if ($cpu) { [int]$cpu.NumberOfLogicalProcessors } else { 0 }
                maxClockMhz = if ($cpu) { [int]$cpu.MaxClockSpeed } else { 0 }
                l2CacheKb = if ($cpu) { [int]$cpu.L2CacheSize } else { 0 }
                l3CacheKb = if ($cpu) { [int]$cpu.L3CacheSize } else { 0 }
            }
            ram = @{
                speedMhz = if ($ramHw -and $ramHw.Speed) { [int]$ramHw.Speed } else { 0 }
                manufacturer = if ($ramHw -and $ramHw.Manufacturer) { $ramHw.Manufacturer.Trim() } else { "System RAM" }
            }
            gpu = @{
                name = if ($gpu -and $gpu.Name) { $gpu.Name.Trim() } else { "System GPU" }
            }
            disk = @{
                mediaType = $mediaType
                model = if ($diskHw -and $diskHw.FriendlyName) { $diskHw.FriendlyName.Trim() } else { "System Drive" }
            }
        }
        $result | ConvertTo-Json -Depth 4
    }

    "GetStats" {
        # 1. Dynamic CPU load & current clock
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cpuLoad = if ($cpu -and $null -ne $cpu.LoadPercentage) { [int]$cpu.LoadPercentage } else { 0 }
        $cpuName = if ($cpu -and $cpu.Name) { $cpu.Name.Trim() } else { "Processor" }

        # 2. RAM usage & WSL state
        $os = Get-CimInstance Win32_OperatingSystem
        $totalRamMb = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
        $freeRamMb = [math]::Round($os.FreePhysicalMemory / 1024, 0)
        $usedRamMb = [math]::Max(0, ($totalRamMb - $freeRamMb))
        $ramPercent = if ($totalRamMb -gt 0) { [math]::Round(($usedRamMb / $totalRamMb) * 100, 1) } else { 0 }

        $wslActive = $null -ne (Get-Process -Name "vmmemWSL", "vmmem" -ErrorAction SilentlyContinue)

        # 3. Primary Drive C:
        $drive = Get-PSDrive C
        $totalDiskGb = [math]::Round(($drive.Used + $drive.Free) / 1GB, 1)
        $freeDiskGb = [math]::Round($drive.Free / 1GB, 1)
        $usedDiskGb = [math]::Round($drive.Used / 1GB, 1)
        $diskPercent = if ($totalDiskGb -gt 0) { [math]::Round(($usedDiskGb / $totalDiskGb) * 100, 1) } else { 0 }

        # 4. Battery
        $battery = Get-CimInstance Win32_Battery | Select-Object -First 1
        $hasBattery = $null -ne $battery
        $battPct = if ($battery) { [int]$battery.EstimatedChargeRemaining } else { 100 }
        $battStatus = if ($battery) {
            switch ($battery.BatteryStatus) {
                1 { "Discharging" }
                2 { "AC Power (Charging)" }
                3 { "Fully Charged" }
                default { "AC Connected" }
            }
        } else { "Desktop / AC" }

        # 5. Active Power Plan
        $schemeLine = (powercfg /getactivescheme 2>$null) -join " "
        $activePlan = "custom"
        $activePlanName = "Custom"
        if ($schemeLine -match "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c") {
            $activePlan = "high"; $activePlanName = "High Performance"
        } elseif ($schemeLine -match "381b4222-f694-41f0-9685-ff5bb260df2e") {
            $activePlan = "balanced"; $activePlanName = "Balanced"
        } elseif ($schemeLine -match "a1841308-3541-4fab-bc81-f71556f20b4a") {
            $activePlan = "saver"; $activePlanName = "Power Saver"
        } elseif ($schemeLine -match "\((.+)\)") {
            $activePlanName = $matches[1].Trim()
        }

        # 6. Live UI tweak states (fast HKCU reads)
        $transVal = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -ErrorAction SilentlyContinue).EnableTransparency
        $menuDelay = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -ErrorAction SilentlyContinue).MenuShowDelay

        # 7. Running process count
        $procCount = (Get-Process).Count

        $result = @{
            cpu = @{
                name = $cpuName
                load = $cpuLoad
                cores = if ($cpu) { [int]$cpu.NumberOfCores } else { 0 }
                threads = if ($cpu) { [int]$cpu.NumberOfLogicalProcessors } else { 0 }
                currentClockMhz = if ($cpu) { [int]$cpu.CurrentClockSpeed } else { 0 }
                maxClockMhz = if ($cpu) { [int]$cpu.MaxClockSpeed } else { 0 }
                l2CacheKb = if ($cpu) { [int]$cpu.L2CacheSize } else { 0 }
                l3CacheKb = if ($cpu) { [int]$cpu.L3CacheSize } else { 0 }
            }
            ram = @{
                totalMb = $totalRamMb
                usedMb = $usedRamMb
                freeMb = $freeRamMb
                percent = $ramPercent
                wslRunning = $wslActive
            }
            disk = @{
                totalGb = $totalDiskGb
                usedGb = $usedDiskGb
                freeGb = $freeDiskGb
                percent = $diskPercent
            }
            battery = @{
                present = $hasBattery
                percent = $battPct
                status = $battStatus
            }
            power = @{
                activePlan = $activePlan
                activePlanName = $activePlanName
            }
            tweaks = @{
                transparencyEnabled = ($transVal -eq 1)
                menuShowDelay = if ($null -ne $menuDelay) { "$menuDelay" } else { "400" }
            }
            processes = $procCount
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }

        $result | ConvertTo-Json -Depth 4
    }

    "FlushRam" {
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)

        $procs = Get-Process
        $trimmedCount = 0
        foreach ($p in $procs) {
            try {
                $p.MinWorkingSet = $p.MinWorkingSet
                $trimmedCount++
            } catch {}
        }

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
                try {
                    Stop-Process -Name $name -Force -ErrorAction Stop
                    $killed += $name
                } catch {}
            }
        }

        @{
            success = $true
            killedCount = $killed.Count
            killedApps = $killed
        } | ConvertTo-Json
    }

    "ScanStorage" {
        $sysTemp = "C:\Windows\Temp"
        $userTemp = [System.IO.Path]::GetTempPath()
        $softDist = "C:\Windows\SoftwareDistribution\Download"
        $minidump = "C:\Windows\Minidump"

        function Get-DirSizeMB($path) {
            if (Test-Path -LiteralPath $path) {
                $size = (Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
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
        $bytesFreed = [double]0
        $filesDeleted = 0

        $r1 = Remove-DirectoryContents -Path ([System.IO.Path]::GetTempPath())
        $bytesFreed += $r1.bytes; $filesDeleted += $r1.count

        $r2 = Remove-DirectoryContents -Path "C:\Windows\Temp"
        $bytesFreed += $r2.bytes; $filesDeleted += $r2.count

        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if (-not $wuService -or $wuService.Status -ne "Running") {
            $r3 = Remove-DirectoryContents -Path "C:\Windows\SoftwareDistribution\Download"
            $bytesFreed += $r3.bytes; $filesDeleted += $r3.count
        }

        $r4 = Remove-DirectoryContents -Path "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
        $bytesFreed += $r4.bytes; $filesDeleted += $r4.count

        @{
            success = $true
            cleanedMb = [math]::Round($bytesFreed / 1MB, 1)
            filesDeleted = $filesDeleted
        } | ConvertTo-Json
    }

    "OptimizeSSD" {
        if (-not (Test-IsAdmin)) {
            @{
                success = $false
                requiresAdmin = $true
                message = "SSD ReTrim requires Administrator privileges. Run Apex Optimizer as Administrator to execute Optimize-Volume."
            } | ConvertTo-Json
            break
        }
        try {
            Optimize-Volume -DriveLetter C -ReTrim -ErrorAction Stop | Out-Null
            @{
                success = $true
                message = "SSD TRIM command executed successfully for drive C:."
            } | ConvertTo-Json
        } catch {
            @{
                success = $false
                message = "SSD ReTrim failed: $($_.Exception.Message)"
            } | ConvertTo-Json
        }
    }

    "SetHibernation" {
        if (-not (Test-IsAdmin)) {
            @{
                success = $false
                requiresAdmin = $true
                message = "Changing hibernation requires Administrator privileges. Please launch Apex Optimizer as Administrator."
            } | ConvertTo-Json
            break
        }

        if ($Mode -eq "reduced") {
            $out = powercfg /h /type reduced 2>&1
            $msg = "Hibernation size reduced (saves ~50% of hiberfil.sys while keeping Fast Startup)."
        } elseif ($Mode -eq "off") {
            $out = powercfg /h off 2>&1
            $msg = "Hibernation disabled (100% of hiberfil.sys storage reclaimed)."
        } else {
            $out = powercfg /h /type full 2>&1
            $msg = "Hibernation restored to full standard mode."
        }

        if ($LASTEXITCODE -ne 0) {
            @{
                success = $false
                message = "Hibernation update failed: $(($out | Out-String).Trim())"
            } | ConvertTo-Json
        } else {
            @{
                success = $true
                message = $msg
            } | ConvertTo-Json
        }
    }

    "SetPowerPlan" {
        if ($Mode -eq "high") {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            if ($LASTEXITCODE -ne 0) {
                powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            }
            $ok = ($LASTEXITCODE -eq 0)
            $msg = if ($ok) { "Switched to High Performance mode." } else { "High Performance plan is unavailable or restricted by Windows Modern Standby on this device." }
        } elseif ($Mode -eq "saver") {
            powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a 2>$null
            $ok = ($LASTEXITCODE -eq 0)
            $msg = if ($ok) { "Switched to Power Saver mode." } else { "Could not activate Power Saver mode." }
        } else {
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
            $ok = ($LASTEXITCODE -eq 0)
            $msg = if ($ok) { "Switched to Balanced mode." } else { "Could not activate Balanced mode." }
        }

        @{
            success = $ok
            message = $msg
        } | ConvertTo-Json
    }

    "FlushDNS" {
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        ipconfig /flushdns 2>$null | Out-Null
        @{
            success = ($LASTEXITCODE -eq 0)
            message = if ($LASTEXITCODE -eq 0) { "DNS Cache Flushed & Resolver Reset." } else { "Failed to flush DNS resolver cache." }
        } | ConvertTo-Json
    }

    "GameBoost" {
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)
        $procs = Get-Process
        foreach ($p in $procs) {
            try { $p.MinWorkingSet = $p.MinWorkingSet } catch {}
        }
        [System.GC]::Collect()

        $bloats = @("PhoneExperienceHost", "BingWallpaper", "CrossDeviceService", "GameBar", "GameBarFTServer", "mshmHost")
        $killed = 0
        foreach ($b in $bloats) {
            $p = Get-Process -Name $b -ErrorAction SilentlyContinue
            if ($p) {
                try {
                    Stop-Process -Name $b -Force -ErrorAction Stop
                    $killed++
                } catch {}
            }
        }

        $pausedSvcs = @()
        foreach ($svcName in @("Spooler", "DiagTrack")) {
            try {
                Stop-Service -Name $svcName -Force -ErrorAction Stop
                $pausedSvcs += $svcName
            } catch {}
        }

        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

        Start-Sleep -Milliseconds 300
        $osAfter = Get-CimInstance Win32_OperatingSystem
        $freeAfter = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
        $freedMb = [math]::Max(0, ($freeAfter - $freeBefore))

        $svcNote = if ($pausedSvcs.Count -gt 0) { "Paused services: $($pausedSvcs -join ', ')." } else { "Run as Admin to pause system services." }
        @{
            success = $true
            freedMb = $freedMb
            killedCount = $killed
            pausedServices = $pausedSvcs
            message = "Game Boost Active: Freed $freedMb MB RAM, stopped $killed bloat apps. $svcNote"
        } | ConvertTo-Json
    }

    "RestoreStandardMode" {
        try { Start-Service -Name Spooler -ErrorAction SilentlyContinue } catch {}
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
        @{
            success = $true
            message = "Standard Balanced Desktop Mode Restored."
        } | ConvertTo-Json
    }

    "LLMMaxBoost" {
        $osBefore = Get-CimInstance Win32_OperatingSystem
        $freeBefore = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)

        $wslWasRunning = $null -ne (Get-Process -Name "vmmemWSL", "vmmem" -ErrorAction SilentlyContinue)
        $wslStopped = $false
        if ($wslWasRunning -and (Get-Command wsl -ErrorAction SilentlyContinue)) {
            try {
                wsl --shutdown 2>$null
                $wslStopped = $true
            } catch {}
        }

        $heavyServices = @("WSearch", "DiagTrack", "SysMain", "Spooler")
        $paused = @()
        foreach ($s in $heavyServices) {
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq "Running") {
                try {
                    Stop-Service -Name $s -Force -ErrorAction Stop
                    $paused += $s
                } catch {}
            }
        }

        $bloats = @("PhoneExperienceHost", "BingWallpaper", "CrossDeviceService", "GameBar", "GameBarFTServer", "mshmHost")
        $killed = 0
        foreach ($b in $bloats) {
            $p = Get-Process -Name $b -ErrorAction SilentlyContinue
            if ($p) {
                try {
                    Stop-Process -Name $b -Force -ErrorAction Stop
                    $killed++
                } catch {}
            }
        }

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

        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $mem = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1

        $wslMsg = if ($wslStopped) { "WSL shut down" } elseif ($wslWasRunning) { "WSL still active" } else { "WSL already idle" }
        @{
            success = $true
            mode = "LLM Maximum Power Mode"
            freeRamMb = $freeAfter
            freedMb = $freedMb
            wslStopped = $wslStopped
            pausedServices = $paused
            killedBloat = $killed
            cpuSpeed = if ($cpu) { "$($cpu.CurrentClockSpeed) MHz" } else { "N/A" }
            l2Cache = if ($cpu) { "$($cpu.L2CacheSize) KB" } else { "N/A" }
            l3Cache = if ($cpu) { "$($cpu.L3CacheSize) KB" } else { "N/A" }
            ramSpeed = if ($mem -and $mem.Speed) { "$($mem.Speed) MHz" } else { "N/A" }
            message = "LLM Boost Active: $wslMsg, $killed bloat tasks cleared. Free RAM: $freeAfter MB (+$freedMb MB freed)."
        } | ConvertTo-Json -Depth 3
    }

    "RestoreServices" {
        $servicesToRestore = @("WSearch", "SysMain", "Spooler")
        $restored = @()
        foreach ($s in $servicesToRestore) {
            try {
                Start-Service -Name $s -ErrorAction Stop
                $restored += $s
            } catch {}
        }
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
        @{
            success = $true
            restoredServices = $restored
            message = "Standard Windows background services & Balanced power mode restored."
        } | ConvertTo-Json
    }

    "TweakSnappiness" {
        try {
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "20" -Type String -Force -ErrorAction Stop
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force -ErrorAction Stop
            @{
                success = $true
                menuShowDelay = "20"
                message = "Instant UI Snappiness enabled: MenuShowDelay set to 20ms & window animations minimized."
            } | ConvertTo-Json
        } catch {
            @{
                success = $false
                message = "Failed to apply UI snappiness tweak: $($_.Exception.Message)"
            } | ConvertTo-Json
        }
    }

    "TweakTCP" {
        if (-not (Test-IsAdmin)) {
            @{
                success = $false
                requiresAdmin = $true
                message = "TCP stack tuning (netsh int tcp) requires Administrator privileges. Run Apex Optimizer as Administrator."
            } | ConvertTo-Json
            break
        }
        $o1 = netsh int tcp set heuristics disabled 2>&1
        $c1 = $LASTEXITCODE
        $o2 = netsh int tcp set global autotuninglevel=normal 2>&1
        $c2 = $LASTEXITCODE
        if ($c1 -eq 0 -and $c2 -eq 0) {
            @{
                success = $true
                message = "TCP Network Stack tuned: Heuristics disabled & Auto-Tuning set to Normal."
            } | ConvertTo-Json
        } else {
            @{
                success = $false
                message = "TCP tuning failed: $(($o1 + ' ' + $o2).Trim())"
            } | ConvertTo-Json
        }
    }

    "TweakTransparency" {
        try {
            $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            $curr = (Get-ItemProperty -Path $path -Name "EnableTransparency" -ErrorAction SilentlyContinue).EnableTransparency
            $next = if ($curr -eq 1) { 0 } else { 1 }
            Set-ItemProperty -Path $path -Name "EnableTransparency" -Value $next -Type DWord -Force -ErrorAction Stop
            $stateText = if ($next -eq 1) { "Enabled" } else { "Disabled (VRAM Saver Active)" }
            @{
                success = $true
                transparencyEnabled = ($next -eq 1)
                message = "Windows DWM Transparency $stateText."
            } | ConvertTo-Json
        } catch {
            @{
                success = $false
                message = "Failed to toggle transparency: $($_.Exception.Message)"
            } | ConvertTo-Json
        }
    }

    "BackupFiles" {
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $targetDrive = if (Test-Path "D:\") { "D:\" } else { "C:\" }
        $backupRoot = Join-Path $targetDrive "ApexBackups"
        $destDir = Join-Path $backupRoot "Backup_$timestamp"
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

        $copiedCount = 0

        $desktopPath = [Environment]::GetFolderPath("Desktop")
        if (Test-Path $desktopPath) {
            $destDesktop = Join-Path $destDir "Desktop"
            New-Item -ItemType Directory -Path $destDesktop -Force | Out-Null
            Get-ChildItem -Path $desktopPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules|\.git|ApexBackups' } | ForEach-Object {
                $relPath = [System.IO.Path]::GetRelativePath($desktopPath, $_.FullName)
                $targetFile = Join-Path $destDesktop $relPath
                $targetFolder = [System.IO.Path]::GetDirectoryName($targetFile)
                if (-not (Test-Path $targetFolder)) { New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null }
                Copy-Item -LiteralPath $_.FullName -Destination $targetFile -Force -ErrorAction SilentlyContinue
                $copiedCount++
            }
        }

        $docsPath = [Environment]::GetFolderPath("MyDocuments")
        if (Test-Path $docsPath) {
            $destDocs = Join-Path $destDir "Documents"
            New-Item -ItemType Directory -Path $destDocs -Force | Out-Null
            Get-ChildItem -Path $docsPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules|\.git|VirtualBox|ApexBackups' } | ForEach-Object {
                $relPath = [System.IO.Path]::GetRelativePath($docsPath, $_.FullName)
                $targetFile = Join-Path $destDocs $relPath
                $targetFolder = [System.IO.Path]::GetDirectoryName($targetFile)
                if (-not (Test-Path $targetFolder)) { New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null }
                Copy-Item -LiteralPath $_.FullName -Destination $targetFile -Force -ErrorAction SilentlyContinue
                $copiedCount++
            }
        }

        $chromeBm = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
        if (Test-Path $chromeBm) {
            $bmDest = Join-Path $destDir "BrowserData"
            New-Item -ItemType Directory -Path $bmDest -Force | Out-Null
            Copy-Item -Path $chromeBm -Destination $bmDest -Force -ErrorAction SilentlyContinue
            $copiedCount++
        }

        $allFiles = Get-ChildItem -Path $destDir -Recurse -File -ErrorAction SilentlyContinue
        $finalSizeMb = [math]::Round((($allFiles | Measure-Object -Property Length -Sum).Sum) / 1MB, 2)
        $finalCount = ($allFiles | Measure-Object).Count

        @{
            success = $true
            backupPath = $destDir
            filesCount = $finalCount
            sizeMb = $finalSizeMb
            message = "Backup completed: $finalCount critical files ($finalSizeMb MB) saved in $destDir"
        } | ConvertTo-Json
    }

    "DeepCleanCache" {
        $bytesFreed = [double]0
        $itemsRemoved = 0

        $r1 = Remove-DirectoryContents -Path $env:TEMP
        $bytesFreed += $r1.bytes; $itemsRemoved += $r1.count

        $r2 = Remove-DirectoryContents -Path "C:\Windows\Temp"
        $bytesFreed += $r2.bytes; $itemsRemoved += $r2.count

        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if (-not $wuService -or $wuService.Status -ne "Running") {
            $r3 = Remove-DirectoryContents -Path "C:\Windows\SoftwareDistribution\Download"
            $bytesFreed += $r3.bytes; $itemsRemoved += $r3.count
        }

        $r4 = Remove-DirectoryContents -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\Cache_Data"
        $bytesFreed += $r4.bytes; $itemsRemoved += $r4.count

        $r5 = Remove-DirectoryContents -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "thumbcache_*.db"
        $bytesFreed += $r5.bytes; $itemsRemoved += $r5.count

        Clear-DnsClientCache -ErrorAction SilentlyContinue

        $freedMb = [math]::Round($bytesFreed / 1MB, 1)

        @{
            success = $true
            cleanedMb = $freedMb
            itemsCount = $itemsRemoved
            message = "Deep Cache Purge: Freed $freedMb MB ($itemsRemoved items) across Temp, Update Cache, Chrome & DNS."
        } | ConvertTo-Json
    }

    "CheckDevEnv" {
        $tools = @()

        $gitVer = try { (git --version 2>$null) } catch { $null }
        $tools += @{
            name = "Git Version Control"
            installed = [bool]$gitVer
            version = if ($gitVer) { $gitVer.Trim() } else { "Not installed" }
        }

        $nodeVer = try { (node -v 2>$null) } catch { $null }
        $tools += @{
            name = "Node.js Runtime"
            installed = [bool]$nodeVer
            version = if ($nodeVer) { $nodeVer.Trim() } else { "Not installed" }
        }

        $pyVer = try { (python --version 2>$null) } catch { $null }
        $tools += @{
            name = "Python Environment"
            installed = [bool]$pyVer
            version = if ($pyVer) { $pyVer.Trim() } else { "Not installed" }
        }

        $execPol = Get-ExecutionPolicy -Scope CurrentUser
        $tools += @{
            name = "PowerShell Execution Policy"
            installed = ($execPol -eq "RemoteSigned" -or $execPol -eq "Bypass" -or $execPol -eq "Unrestricted")
            version = "$execPol"
        }

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

        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
            $actions += "PowerShell script policy set to RemoteSigned"
        } catch {}

        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force -ErrorAction Stop
            $actions += "Developer AppModelUnlock enabled"
        } catch {}

        if (Get-Command git -ErrorAction SilentlyContinue) {
            git config --global core.autocrlf true 2>$null
            git config --global init.defaultBranch main 2>$null
            $actions += "Git global defaults configured"
        }

        @{
            success = ($actions.Count -gt 0)
            actions = $actions
            message = if ($actions.Count -gt 0) { "Developer environment primed: $($actions -join '; ')." } else { "No developer environment changes could be applied." }
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
        ipconfig /flushdns 2>$null | Out-Null
        $dnsOk = ($LASTEXITCODE -eq 0)

        $winsockOk = $false
        if (Test-IsAdmin) {
            netsh winsock reset 2>$null | Out-Null
            $winsockOk = ($LASTEXITCODE -eq 0)
        }

        if ($winsockOk) {
            $msg = "Network reset complete: DNS resolver flushed & Winsock catalog repaired."
        } elseif ($dnsOk) {
            $msg = "DNS resolver flushed. Run as Administrator to also reset the Winsock catalog."
        } else {
            $msg = "Network reset failed."
        }

        @{
            success = $dnsOk
            winsockReset = $winsockOk
            message = $msg
        } | ConvertTo-Json
    }

    "WindowControl" {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ApexWinCtrl {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@ -ErrorAction SilentlyContinue

        $hwnd = [ApexWinCtrl]::GetForegroundWindow()
        if ($hwnd -eq [IntPtr]::Zero) {
            @{ success = $false; message = "No active window handle found." } | ConvertTo-Json
            break
        }

        if ($Mode -eq "minimize") {
            [ApexWinCtrl]::ShowWindow($hwnd, 6) | Out-Null
        } elseif ($Mode -eq "maximize") {
            $isMax = [ApexWinCtrl]::IsZoomed($hwnd)
            [ApexWinCtrl]::ShowWindow($hwnd, $(if ($isMax) { 9 } else { 3 })) | Out-Null
        } elseif ($Mode -eq "close") {
            [ApexWinCtrl]::PostMessage($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        }

        @{
            success = $true
            mode = $Mode
        } | ConvertTo-Json
    }

    default {
        @{ success = $false; error = "Unknown action $Action" } | ConvertTo-Json
    }
}
