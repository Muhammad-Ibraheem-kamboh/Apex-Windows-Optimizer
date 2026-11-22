$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
$html = $wc.DownloadString("https://deb.parrot.sh/parrot/iso/6.3.2/")
[System.Text.RegularExpressions.Regex]::Matches($html, 'href="([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -notmatch '^\?' -and $_ -ne '../' }
