$oneDrive = $env:OneDrive
if (-not $oneDrive) {
    $oneDrive = (Get-ItemProperty 'HKCU:\Software\Microsoft\OneDrive' -ErrorAction SilentlyContinue).UserFolder
}
if (-not $oneDrive) {
    # Check common paths
    $paths = Get-ChildItem "C:\Users\Administrator" -Directory -Filter "OneDrive*"
    if ($paths) { $oneDrive = $paths[0].FullName }
}

$dItems = Get-ChildItem -Path "D:\" -Force | Where-Object { $_.Name -notmatch '\$RECYCLE\.BIN|System Volume Information' }
$totalBytes = 0
$fileCount = 0
foreach ($item in $dItems) {
    if ($item.PSIsContainer) {
        $files = Get-ChildItem -Path $item.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $totalBytes += $f.Length
            $fileCount++
        }
    } else {
        $totalBytes += $item.Length
        $fileCount++
    }
}

$proc = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue

[PSCustomObject]@{
    OneDrivePath = $oneDrive
    OneDriveExists = (Test-Path $oneDrive)
    OneDriveRunning = [bool]$proc
    TotalFilesOnD = $fileCount
    TotalSizeMB = [math]::Round($totalBytes / 1MB, 2)
    TotalSizeGB = [math]::Round($totalBytes / 1GB, 3)
    Folders = ($dItems.Name -join ", ")
} | Format-List
