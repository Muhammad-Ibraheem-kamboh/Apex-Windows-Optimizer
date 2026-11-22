$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
[PSCustomObject]@{
    Manufacturer = $cs.Manufacturer
    Model = $cs.Model
    BIOS_Version = $bios.SMBIOSBIOSVersion
    ReleaseDate = $bios.ReleaseDate
} | Format-List
