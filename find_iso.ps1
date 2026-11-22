$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
$versions = @("6.3.2", "6.2", "6.1", "6.0", "5.3")
foreach ($v in $versions) {
    try {
        $html = $wc.DownloadString("https://deb.parrot.sh/parrot/iso/$v/")
        $m = [System.Text.RegularExpressions.Regex]::Matches($html, 'href="([^"]+\.iso)"')
        if ($m) {
            Write-Output "=== Found in $v ==="
            $m | ForEach-Object { Write-Output "https://deb.parrot.sh/parrot/iso/$v/$($_.Groups[1].Value)" }
            break
        }
    } catch {}
}
