$oneDrive = "C:\Users\Administrator\OneDrive - Institute of Business Administration"
$backupTarget = "$oneDrive\Drive_D_Complete_Backup"

if (-not (Test-Path $backupTarget)) {
    New-Item -ItemType Directory -Path $backupTarget -Force | Out-Null
}

Write-Output "[1/2] Backing up D:\ to $backupTarget..."
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Using call operator with exact string literals
& robocopy.exe "D:\" $backupTarget /E /XD '$RECYCLE.BIN' 'System Volume Information' /R:1 /W:1 /MT:8 /NFL /NDL /NP /NJH /NJS

$stopwatch.Stop()
Write-Output "[2/2] Finished copy in $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1))s"

# Verification
$copiedFiles = Get-ChildItem -Path $backupTarget -Recurse -File -Force -ErrorAction SilentlyContinue
$copiedBytes = ($copiedFiles | Measure-Object -Property Length -Sum).Sum

[PSCustomObject]@{
    BackupFolder = $backupTarget
    FilesCopied = $copiedFiles.Count
    TotalSizeMB = [math]::Round($copiedBytes / 1MB, 2)
    TotalSizeGB = [math]::Round($copiedBytes / 1GB, 3)
} | Format-List
