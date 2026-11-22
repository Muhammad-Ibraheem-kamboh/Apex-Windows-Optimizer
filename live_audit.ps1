# 1. Battery & Power Check
$battery = Get-CimInstance Win32_Battery | Select-Object -First 1
$battPct = if ($battery) { $battery.EstimatedChargeRemaining } else { 100 }
$isCharging = if ($battery) {
    ($battery.BatteryStatus -eq 2) -or ($battery.BatteryStatus -eq 3)
} else { $true }

# 2. BitLocker Check (CRITICAL)
$bitlockerC = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
$bitlockerD = Get-BitLockerVolume -MountPoint "D:" -ErrorAction SilentlyContinue
$blStatusC = if ($bitlockerC) { $bitlockerC.ProtectionStatus } else { "Off / None" }
$blStatusD = if ($bitlockerD) { $bitlockerD.ProtectionStatus } else { "Off / None" }

# 3. Internet Speed Check (10MB test)
$speedMbps = 0
try {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $wc = New-Object System.Net.WebClient
    $null = $wc.DownloadData("https://speed.cloudflare.com/__down?bytes=15000000")
    $sw.Stop()
    $speedBytesPerSec = 15000000 / $sw.Elapsed.TotalSeconds
    $speedMbps = [math]::Round(($speedBytesPerSec * 8) / 1MB, 2)
} catch {
    $speedMbps = "Error: $_"
}

# 4. Disk & Partition Info
$cDrive = Get-PSDrive C
$dDrive = Get-PSDrive D

[PSCustomObject]@{
    BatteryPercent = $battPct
    IsChargingOrAC = $isCharging
    BitLocker_DriveC = $blStatusC
    BitLocker_DriveD = $blStatusD
    DownloadSpeedMbps = $speedMbps
    FreeGB_C = [math]::Round($cDrive.Free / 1GB, 1)
    FreeGB_D = [math]::Round($dDrive.Free / 1GB, 1)
} | Format-List
