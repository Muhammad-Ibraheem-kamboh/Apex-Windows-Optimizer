$secBoot = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -ErrorAction SilentlyContinue
$status = if ($secBoot) {
    if ($secBoot.UEFISecureBootEnabled -eq 0) { "Disabled (SUCCESS!)" }
    elseif ($secBoot.UEFISecureBootEnabled -eq 1) { "Enabled" }
    else { "Unknown: $($secBoot.UEFISecureBootEnabled)" }
} else { "Registry key not found" }

[PSCustomObject]@{
    SecureBootState = $status
    RawValue = if ($secBoot) { $secBoot.UEFISecureBootEnabled } else { "N/A" }
} | Format-List
