$url = "https://deb.parrot.sh/parrot/iso/7.4/Parrot-security-7.4_amd64.iso"
$targetPath = "D:\ISOs\Parrot-security-7.4_amd64.iso"
$progressJson = "D:\ISOs\download_progress.json"

Write-Output "Starting Parrot Security 7.4 ISO Download..."

# 1. Get remote content length
$req = [System.Net.HttpWebRequest]::Create($url)
$req.Method = 'HEAD'
$req.UserAgent = 'Mozilla/5.0'
$resp = $req.GetResponse()
$totalBytes = $resp.ContentLength
$resp.Close()

Write-Output "Total ISO Size: $([math]::Round($totalBytes / 1GB, 2)) GB ($totalBytes bytes)"

# 2. Check if resuming is needed
$existingBytes = 0
$fileMode = [System.IO.FileMode]::Create
if (Test-Path $targetPath) {
    $existingBytes = (Get-Item $targetPath).Length
    if ($existingBytes -eq $totalBytes) {
        Write-Output "File is already fully downloaded! Size: $([math]::Round($existingBytes / 1GB, 2)) GB"
        @{
            status = "completed"
            percent = 100
            downloadedMB = [math]::Round($totalBytes / 1MB, 2)
            totalMB = [math]::Round($totalBytes / 1MB, 2)
        } | ConvertTo-Json | Set-Content $progressJson
        exit 0
    } elseif ($existingBytes -lt $totalBytes) {
        Write-Output "Resuming download from byte $existingBytes..."
        $fileMode = [System.IO.FileMode]::Append
    }
}

# 3. Open HTTP Stream with Range
$getReq = [System.Net.HttpWebRequest]::Create($url)
$getReq.Method = 'GET'
$getReq.UserAgent = 'Mozilla/5.0'
if ($existingBytes -gt 0) {
    $getReq.AddRange([int64]$existingBytes)
}

$getResp = $getReq.GetResponse()
$stream = $getResp.GetResponseStream()
$fileStream = New-Object System.IO.FileStream $targetPath, $fileMode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read

$buffer = New-Object byte[] (1024 * 1024 * 2) # 2MB buffer
$currentDownloaded = $existingBytes
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$lastLogTime = [System.Diagnostics.Stopwatch]::StartNew()

while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fileStream.Write($buffer, 0, $bytesRead)
    $currentDownloaded += $bytesRead

    if ($lastLogTime.ElapsedMilliseconds -ge 2000) {
        $lastLogTime.Restart()
        $pct = [math]::Round(($currentDownloaded / $totalBytes) * 100, 1)
        $speed = [math]::Round((($currentDownloaded - $existingBytes) / 1MB) / [math]::Max(1, $stopwatch.Elapsed.TotalSeconds), 2)
        $remainingSecs = if ($speed -gt 0) { [math]::Round((($totalBytes - $currentDownloaded) / 1MB) / $speed, 0) } else { 0 }
        
        $stat = @{
            status = "downloading"
            percent = $pct
            downloadedMB = [math]::Round($currentDownloaded / 1MB, 1)
            totalMB = [math]::Round($totalBytes / 1MB, 1)
            downloadedGB = [math]::Round($currentDownloaded / 1GB, 2)
            totalGB = [math]::Round($totalBytes / 1GB, 2)
            speedMBs = $speed
            etaMinutes = [math]::Round($remainingSecs / 60, 1)
        }
        $stat | ConvertTo-Json | Set-Content $progressJson
    }
}

$fileStream.Flush()
$fileStream.Close()
$stream.Close()
$getResp.Close()
$stopwatch.Stop()

Write-Output "Download Finished! Total Size: $([math]::Round($currentDownloaded / 1GB, 2)) GB"

@{
    status = "completed"
    percent = 100
    downloadedMB = [math]::Round($totalBytes / 1MB, 1)
    totalMB = [math]::Round($totalBytes / 1MB, 1)
    downloadedGB = [math]::Round($totalBytes / 1GB, 2)
    totalGB = [math]::Round($totalBytes / 1GB, 2)
} | ConvertTo-Json | Set-Content $progressJson
