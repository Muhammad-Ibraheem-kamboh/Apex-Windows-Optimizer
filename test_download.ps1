$url = "https://deb.parrot.sh/parrot/iso/7.4/Parrot-security-7.4_amd64.iso"
$testChunkPath = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\chunk.tmp"

try {
    $req = [System.Net.HttpWebRequest]::Create($url)
    $req.AddRange(0, 5242880) # 5MB
    $req.UserAgent = "Mozilla/5.0"
    $resp = $req.GetResponse()
    $stream = $resp.GetResponseStream()
    $fs = [System.IO.File]::Create($testChunkPath)
    $buffer = New-Object byte[] 65536
    $totalRead = 0
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fs.Write($buffer, 0, $read)
        $totalRead += $read
    }
    $sw.Stop()
    $fs.Close()
    $stream.Close()
    $resp.Close()

    $speed = [math]::Round(($totalRead / 1MB) / $sw.Elapsed.TotalSeconds, 2)
    Remove-Item -Path $testChunkPath -Force -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Status = "Success"
        BytesRead = $totalRead
        SpeedMBs = $speed
    }
} catch {
    Write-Output "Error: $_"
}
