# Test speed with standard headers
$testUrl = "https://proof.ovh.net/files/10Mb.dat"
$speedMbps = 0
try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $data = $wc.DownloadData($testUrl)
    $sw.Stop()
    $speedBytes = $data.Length / $sw.Elapsed.TotalSeconds
    $speedMbps = [math]::Round(($speedBytes * 8) / 1MB, 2)
    $speedMBs = [math]::Round($speedBytes / 1MB, 2)
} catch {
    $speedMbps = "Failed: $_"
    $speedMBs = 0
}

[PSCustomObject]@{
    SpeedMbps = $speedMbps
    SpeedMBs = $speedMBs
} | Format-List
