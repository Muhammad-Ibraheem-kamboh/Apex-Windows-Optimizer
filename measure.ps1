$path = 'C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer'
$desktopLnk = 'C:\Users\Administrator\Desktop\Apex Optimizer.cmd'

# 1. Measure Storage (Disk Space)
$files = Get-ChildItem -Path $path -Recurse -File
$diskBytes = ($files | Measure-Object -Property Length -Sum).Sum
if (Test-Path $desktopLnk) {
    $diskBytes += (Get-Item $desktopLnk).Length
}
$diskKb = [math]::Round($diskBytes / 1KB, 2)
$diskMb = [math]::Round($diskBytes / 1MB, 2)

# File breakdown
$breakdown = $files | Select-Object Name, @{Name="SizeKB"; Expression={[math]::Round($_.Length / 1KB, 2)}}

# 2. Measure RAM Memory
# Background Node server process
$nodeProcs = Get-CimInstance Win32_Process -Filter 'Name="node.exe"' | Where-Object { $_.CommandLine -like '*server.js*' -or $_.CommandLine -like '*ApexOptimizer*' }
$nodeRamMb = 0
$nodePids = @()
if ($nodeProcs) {
    foreach ($p in $nodeProcs) {
        $procObj = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
        if ($procObj) {
            $nodeRamMb += [math]::Round($procObj.WorkingSet64 / 1MB, 2)
            $nodePids += $p.ProcessId
        }
    }
}

# Edge App Window (if running)
$edgeProcs = Get-CimInstance Win32_Process -Filter 'Name="msedge.exe"' | Where-Object { $_.CommandLine -like '*48888*' }
$edgeRamMb = 0
$edgePids = @()
if ($edgeProcs) {
    foreach ($p in $edgeProcs) {
        $procObj = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
        if ($procObj) {
            $edgeRamMb += [math]::Round($procObj.WorkingSet64 / 1MB, 2)
            $edgePids += $p.ProcessId
        }
    }
}

[PSCustomObject]@{
    Disk_Total_KB = $diskKb
    Disk_Total_MB = $diskMb
    Files_Count = $files.Count + 1
    Background_Node_RAM_MB = $nodeRamMb
    Background_Node_PIDs = ($nodePids -join ", ")
    UI_Window_Edge_RAM_MB = $edgeRamMb
    UI_Window_PIDs = ($edgePids -join ", ")
    Total_Combined_RAM_MB = ($nodeRamMb + $edgeRamMb)
} | Format-List

Write-Output "`n--- File by File Storage Breakdown ---"
$breakdown | Format-Table -AutoSize
