$desktop = [System.Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop "Apex Optimizer.lnk"
$oldCmdPath = Join-Path $desktop "Apex Optimizer.cmd"

# Remove old .cmd file if present
if (Test-Path $oldCmdPath) {
    Remove-Item -Path $oldCmdPath -Force
}

$targetVbs = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\launch.vbs"
$iconPath = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\assets\apex.ico"
$workDir = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer"

$wsh = New-Object -ComObject WScript.Shell
$sc = $wsh.CreateShortcut($shortcutPath)
$sc.TargetPath = "wscript.exe"
$sc.Arguments = "`"$targetVbs`""
$sc.WorkingDirectory = $workDir
$sc.IconLocation = "$iconPath,0"
$sc.Description = "Apex Windows Optimizer Pro - AI Performance Suite"
$sc.WindowStyle = 1
$sc.Save()

Write-Output "Shortcut created: $(Test-Path $shortcutPath)"
