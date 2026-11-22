# Check OneDrive sync status
$process = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
$backupPath = "C:\Users\Administrator\OneDrive - Institute of Business Administration\Drive_D_Complete_Backup"

[PSCustomObject]@{
    OneDriveProcessRunning = [bool]$process
    IBA_Account = "m.ibraheem.36930@khi.iba.edu.pk"
    LocalBackupPath = $backupPath
    LocalFolderExists = (Test-Path $backupPath)
    ItemsInFolder = (Get-ChildItem $backupPath).Name -join ", "
} | Format-List
