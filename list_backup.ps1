$backupPath = "C:\Users\Administrator\OneDrive - Institute of Business Administration\Drive_D_Complete_Backup"
if (Test-Path $backupPath) {
    Get-ChildItem -Path $backupPath -Directory | ForEach-Object {
        $files = Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
        $bytes = ($files | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Folder = $_.Name
            Files = $files.Count
            SizeMB = [math]::Round($bytes / 1MB, 2)
        }
    } | Format-Table -AutoSize
}
