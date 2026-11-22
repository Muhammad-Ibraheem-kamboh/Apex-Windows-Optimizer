try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $html = $wc.DownloadString("https://deb.parrot.sh/parrot/iso/")
    $matches = [System.Text.RegularExpressions.Regex]::Matches($html, 'href="([0-9\.]+)/"')
    $versions = @()
    foreach ($m in $matches) {
        $versions += $m.Groups[1].Value
    }
    $versions | Select-Object -Unique | Sort-Object
} catch {
    Write-Output "Error: $_"
}
