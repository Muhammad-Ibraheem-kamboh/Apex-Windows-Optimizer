$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
try {
    $html = $wc.DownloadString("https://www.parrotsec.org/download/")
    [System.Text.RegularExpressions.Regex]::Matches($html, 'https?://[^\s"''<>]+\.iso') | ForEach-Object { $_.Value } | Select-Object -Unique
} catch {
    Write-Output "Error: $_"
}
