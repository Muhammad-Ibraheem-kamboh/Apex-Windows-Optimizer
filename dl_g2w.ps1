try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    $wc.Headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    $out = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\g2w.zip"
    $wc.DownloadFile("https://sourceforge.net/projects/grub2win/files/latest/download", $out)
    [PSCustomObject]@{
        Success = Test-Path $out
        SizeKB = (Get-Item $out).Length / 1KB
    }
} catch {
    Write-Output "Error: $_"
}
