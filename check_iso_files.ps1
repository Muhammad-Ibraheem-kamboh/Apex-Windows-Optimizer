$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
try {
    $html64 = $wc.DownloadString("https://deb.parrot.sh/parrot/iso/6.4/")
    [System.Text.RegularExpressions.Regex]::Matches($html64, 'href="([^"]+\.iso)"') | ForEach-Object { $_.Groups[1].Value }
} catch {
    Write-Output "6.4 error: $_"
}
