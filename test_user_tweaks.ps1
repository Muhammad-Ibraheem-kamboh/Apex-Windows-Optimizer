$results = @{}

# 1. MenuShowDelay (Instant right-click / menus)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "20" -Type String -Force
$results["MenuShowDelay"] = "20ms (Instant)"

# 2. GameDVR Buffer (saves Intel HD 620 GPU memory)
if (Test-Path "HKCU:\System\GameConfigStore") {
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
    $results["GameDVR"] = "Disabled (Frees Intel HD Graphics VRAM)"
}

# 3. Explorer Window Animation Delay Reduction
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force
$results["MinAnimate"] = "Disabled window minimize/maximize animation delays"

# 4. Transparency Effects Toggle
$themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (Test-Path $themePath) {
    $currentTrans = (Get-ItemProperty $themePath).EnableTransparency
    $results["CurrentTransparency"] = $currentTrans
}

$results | ConvertTo-Json
