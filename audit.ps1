$sysmain = (Get-Service SysMain -ErrorAction SilentlyContinue).Status
$lastAccess = (fsutil behavior query disablelastaccess)
$doConfig = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -ErrorAction SilentlyContinue
$doMode = if ($doConfig) { $doConfig.DODownloadMode } else { "Default (P2P on)" }
$vbs = (Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction SilentlyContinue).VirtualizationBasedSecurityStatus
$multimedia = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -ErrorAction SilentlyContinue
$sysResp = if ($multimedia) { $multimedia.SystemResponsiveness } else { "Default" }
$netThrottle = if ($multimedia) { $multimedia.NetworkThrottlingIndex } else { "Default" }

[PSCustomObject]@{
    SysMain = $sysmain
    LastAccess = ($lastAccess -join ' | ')
    DODownloadMode = $doMode
    VBS_Status = $vbs
    SystemResponsiveness = $sysResp
    NetworkThrottlingIndex = $netThrottle
} | Format-List
