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

# Flush Windows Shell icon cache so Desktop shortcut displays updated icon immediately
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ApexShellRefresh {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@ -ErrorAction SilentlyContinue
[ApexShellRefresh]::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)
if (Test-Path "$env:WINDIR\System32\ie4uinit.exe") {
    Start-Process -FilePath "$env:WINDIR\System32\ie4uinit.exe" -ArgumentList "-show" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
}

Write-Output "Shortcut created: $(Test-Path $shortcutPath)"
