param(
    [string]$Url = "https://bunny.deb.parrot.sh/parrot/iso/7.4/Parrot-security-7.4_amd64.iso",
    [string]$TargetPath = "D:\ISOs\Parrot-security-7.4_amd64.iso",
    [string]$ProgressPath = "D:\ISOs\download_progress.json",
    [int64]$ExpectedSize = 8682078208
)

$targetDir = Split-Path $TargetPath -Parent
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "=== Starting Robust Resumable curl Download ==="
Write-Host "URL: $Url"
Write-Host "Target: $TargetPath"
Write-Host "Expected Size: $([math]::Round($ExpectedSize / 1GB, 2)) GB ($ExpectedSize bytes)"

$startTime = [System.Diagnostics.Stopwatch]::StartNew()
$lastCheckTime = [System.Diagnostics.Stopwatch]::StartNew()
$lastBytes = 0
if (Test-Path $TargetPath) {
    $lastBytes = (Get-Item $TargetPath).Length
}
$initialBytes = $lastBytes

# Start monitor job to continuously update progress JSON
$monitorScript = {
    param($TargetPath, $ProgressPath, $ExpectedSize, $InitialBytes)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $prevBytes = $InitialBytes
    $prevTime = [System.Diagnostics.Stopwatch]::StartNew()
    
    while ($true) {
        Start-Sleep -Seconds 3
        if (Test-Path $TargetPath) {
            $curBytes = (Get-Item $TargetPath).Length
            $elapsedSec = $prevTime.Elapsed.TotalSeconds
            $deltaBytes = $curBytes - $prevBytes
            $speedMBs = 0
            if ($elapsedSec -gt 0 -and $deltaBytes -gt 0) {
                $speedMBs = [math]::Round(($deltaBytes / 1MB) / $elapsedSec, 2)
            }
            $prevBytes = $curBytes
            $prevTime.Restart()

            $pct = [math]::Round(($curBytes / $ExpectedSize) * 100, 1)
            $remainingBytes = [math]::Max(0, $ExpectedSize - $curBytes)
            $etaMinutes = 0
            if ($speedMBs -gt 0) {
                $etaMinutes = [math]::Round(($remainingBytes / 1MB) / ($speedMBs * 60), 1)
            }

            $info = @{
                status = if ($curBytes -ge $ExpectedSize) { "completed" } else { "downloading" }
                percent = $pct
                downloadedMB = [math]::Round($curBytes / 1MB, 1)
                totalMB = [math]::Round($ExpectedSize / 1MB, 1)
                downloadedGB = [math]::Round($curBytes / 1GB, 2)
                totalGB = [math]::Round($ExpectedSize / 1GB, 2)
                speedMBs = $speedMBs
                etaMinutes = $etaMinutes
            }
            $info | ConvertTo-Json | Set-Content $ProgressPath
            
            if ($curBytes -ge $ExpectedSize) { break }
        }
    }
}

$monitorJob = Start-Job -ScriptBlock $monitorScript -ArgumentList $TargetPath, $ProgressPath, $ExpectedSize, $initialBytes

# Download loop with auto-retry
$maxRetries = 50
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    if (Test-Path $TargetPath) {
        $curSize = (Get-Item $TargetPath).Length
        if ($curSize -ge $ExpectedSize) {
            Write-Host "File is fully downloaded! Size: $curSize bytes"
            break
        }
    }

    Write-Host "Invoking curl.exe (Attempt $($retryCount + 1))..."
    # curl options:
    # -L: follow redirects
    # -C -: resume from current file offset
    # --retry 5: retry transient errors
    # -o: output file
    # -s: silent so no console spam
    & curl.exe -L -C - --retry 5 --retry-delay 2 -o $TargetPath $Url

    if (Test-Path $TargetPath) {
        $afterSize = (Get-Item $TargetPath).Length
        if ($afterSize -ge $ExpectedSize) {
            Write-Host "Download verified complete!"
            break
        }
    }

    $retryCount++
    Write-Host "Connection interrupted, retrying in 3 seconds..."
    Start-Sleep -Seconds 3
}

Stop-Job $monitorJob -ErrorAction SilentlyContinue
Remove-Job $monitorJob -ErrorAction SilentlyContinue

# Final verification
if (Test-Path $TargetPath) {
    $finalSize = (Get-Item $TargetPath).Length
    if ($finalSize -ge $ExpectedSize) {
        Write-Host "SUCCESS: Download Complete. Final Size: $([math]::Round($finalSize / 1GB, 2)) GB"
        @{
            status = "completed"
            percent = 100
            downloadedMB = [math]::Round($finalSize / 1MB, 1)
            totalMB = [math]::Round($ExpectedSize / 1MB, 1)
            downloadedGB = [math]::Round($finalSize / 1GB, 2)
            totalGB = [math]::Round($ExpectedSize / 1GB, 2)
            speedMBs = 0
            etaMinutes = 0
        } | ConvertTo-Json | Set-Content $ProgressPath
    } else {
        Write-Error "Download incomplete. Size: $finalSize / $ExpectedSize"
    }
}
