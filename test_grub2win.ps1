$url = "https://downloads.sourceforge.net/project/grub2win/grub2win.zip"
try {
    $req = [System.Net.HttpWebRequest]::Create($url)
    $req.Method = 'HEAD'
    $req.UserAgent = 'Mozilla/5.0'
    $req.AllowAutoRedirect = $true
    $resp = $req.GetResponse()
    [PSCustomObject]@{
        Status = [int]$resp.StatusCode
        FinalUrl = $resp.ResponseUri.ToString()
        SizeMB = [math]::Round($resp.ContentLength / 1MB, 2)
    }
} catch {
    Write-Output "Error: $_"
}
