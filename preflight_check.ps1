# Measure Battery & Network Speed
$battery = Get-CimInstance Win32_Battery | Select-Object -First 1
$battPct = if ($battery) { $battery.EstimatedChargeRemaining } else { 100 }
$battStatus = if ($battery) {
    switch ($battery.BatteryStatus) {
        1 { "Discharging (On Battery)" }
        2 { "AC Power (Charging)" }
        3 { "Fully Charged" }
        default { "AC Connected" }
    }
} else { "Desktop / AC" }
$timeRemainingMin = if ($battery -and $battery.EstimatedRunTime -lt 71582788) { $battery.EstimatedRunTime } else { "Unlimited (AC)" }

# Test Download Speed by fetching a 20MB test chunk
$speedMbps = 0
$testUrl = "https://speed.cloudflare.com/__down?bytes=25000000" # 25 MB test file
try {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $wc = New-Object System.Net.WebClient
    $null = $wc.DownloadData($testUrl)
    $sw.Stop()
    $seconds = $sw.Elapsed.TotalSeconds
    $speedBytesPerSec = 25000000 / $seconds
    $speedMbps = [math]::Round(($speedBytesPerSec * 8) / 1MB, 2)
    $speedMBs = [math]::Round($speedBytesPerSec / 1MB, 2)
} catch {
    $speedMbps = "Test failed: $_"
    $speedMBs = 0
}

# Free Space on Drives
$cDrive = Get-PSDrive C
$dDrive = Get-PSDrive D

[PSCustomObject]@{
    BatteryPercent = $battPct
    BatteryStatus = $battStatus
    EstimatedRunTimeMin = $timeRemainingMin
    InternetSpeedMbps = $speedMbps
    InternetSpeedMBs = $speedMBs
    DriveC_FreeGB = [math]::Round($cDrive.Free / 1GB, 1)
    DriveD_FreeGB = [math]::Round($dDrive.Free / 1GB, 1)
} | Format-List
