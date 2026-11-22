try {
    $req = [System.Net.HttpWebRequest]::Create('https://deb.parrot.sh/parrot/iso/7.4/Parrot-home-7.4_amd64.iso')
    $req.Method = 'HEAD'
    $req.UserAgent = 'Mozilla/5.0'
    $resp = $req.GetResponse()
    [PSCustomObject]@{
        Name = "Parrot-home-7.4"
        StatusCode = [int]$resp.StatusCode
        ContentLengthGB = [math]::Round($resp.ContentLength / 1GB, 2)
        ContentLengthMB = [math]::Round($resp.ContentLength / 1MB, 2)
    }
} catch {
    Write-Output "Error: $_"
}
