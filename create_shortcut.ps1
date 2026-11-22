$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$desktop = [System.Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop "Apex Optimizer.lnk"

$targetVbs = Join-Path $scriptDir "launch.vbs"
$iconPath = Join-Path $scriptDir "assets\apex.ico"
$workDir = $scriptDir

$wsh = New-Object -ComObject WScript.Shell
$sc = $wsh.CreateShortcut($shortcutPath)
$sc.TargetPath = "wscript.exe"
$sc.Arguments = "`"$targetVbs`""
$sc.WorkingDirectory = $workDir
if (Test-Path $iconPath) {
    $sc.IconLocation = "$iconPath,0"
}
$sc.Description = "Apex Windows Optimizer Pro - AI Performance Suite"
$sc.WindowStyle = 1
$sc.Save()

Write-Output "Shortcut created: $(Test-Path $shortcutPath)"
