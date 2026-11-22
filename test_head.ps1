try {
    $req = [System.Net.HttpWebRequest]::Create('https://deb.parrot.sh/parrot/iso/6.3.2/Parrot-security-6.3.2_amd64.iso')
    $req.Method = 'HEAD'
    $req.UserAgent = 'Mozilla/5.0'
    $resp = $req.GetResponse()
    [PSCustomObject]@{
        StatusCode = [int]$resp.StatusCode
        ContentLengthGB = [math]::Round($resp.ContentLength / 1GB, 2)
        ContentLengthMB = [math]::Round($resp.ContentLength / 1MB, 2)
        ContentLengthBytes = $resp.ContentLength
    }
} catch {
    Write-Output "Error: $_"
}
