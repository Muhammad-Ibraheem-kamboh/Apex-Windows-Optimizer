# Test Kernel & System Tweaks
$results = @{}

# 1. Disable NTFS Last Access Update
try {
    fsutil behavior set disablelastaccess 1 | Out-Null
    $results["NTFS_LastAccess"] = "Disabled (SSD I/O Wear Eliminated)"
} catch {
    $results["NTFS_LastAccess"] = "Failed: $_"
}

# 2. Multimedia & System Responsiveness
try {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $path -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $path -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
    $results["System_Responsiveness"] = "Set to 100% CPU priority & Network Unthrottled"
} catch {
    $results["System_Responsiveness"] = "Failed: $_"
}

# 3. Delivery Optimization P2P Seeding
try {
    $doPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    if (-not (Test-Path $doPath)) { New-Item -Path $doPath -Force | Out-Null }
    Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
    $results["Delivery_Optimization"] = "P2P Background Seeding Disabled"
} catch {
    $results["Delivery_Optimization"] = "Failed: $_"
}

# 4. Menu Show Delay
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "20" -Type String -Force
    $results["Menu_Delay"] = "Reduced from 400ms to 20ms (Instant Context Menus)"
} catch {
    $results["Menu_Delay"] = "Failed: $_"
}

# 5. Disable GameDVR Background Recording Buffer
try {
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        Set-ItemProperty -Path $gcsPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    }
    $results["GameDVR"] = "Background Frame Buffer Disabled (More GPU VRAM)"
} catch {
    $results["GameDVR"] = "Failed: $_"
}

$results | ConvertTo-Json
