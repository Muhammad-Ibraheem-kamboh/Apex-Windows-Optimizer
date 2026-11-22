# Test downloading grub2win with WebSession
$url = "https://sourceforge.net/projects/grub2win/files/latest/download"
$out = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\grub2win.zip"

try {
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    # First get the page to get cookies
    $page = Invoke-WebRequest -Uri "https://sourceforge.net/projects/grub2win/" -WebSession $session -Headers @{"Accept"="text/html,application/xhtml+xml"}
    
    # Now follow download
    Invoke-WebRequest -Uri $url -WebSession $session -OutFile $out -Headers @{"Referer"="https://sourceforge.net/projects/grub2win/"}
    
    [PSCustomObject]@{
        Success = (Test-Path $out)
        SizeKB = [math]::Round((Get-Item $out).Length / 1KB, 2)
    }
} catch {
    Write-Output "Error: $_"
}
