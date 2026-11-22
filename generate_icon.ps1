Add-Type -AssemblyName System.Drawing

$assetsDir = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer\assets"
if (-not (Test-Path $assetsDir)) { New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null }

$iconPath = Join-Path $assetsDir "apex.ico"
$pngPath = Join-Path $assetsDir "apex.png"

$bmp = New-Object System.Drawing.Bitmap 256, 256
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Clear background (transparent)
$g.Clear([System.Drawing.Color]::Transparent)

# Outer Dark Circle
$rect = New-Object System.Drawing.Rectangle 8, 8, 240, 240
$p1 = New-Object System.Drawing.Point 0, 0
$p2 = New-Object System.Drawing.Point 256, 256
$c1 = [System.Drawing.Color]::FromArgb(255, 14, 17, 24)
$c2 = [System.Drawing.Color]::FromArgb(255, 24, 28, 42)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList $p1, $p2, $c1, $c2
$g.FillEllipse($bgBrush, $rect)

# Cyan/Indigo Glow Rings
$penRing = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 99, 102, 241)), 6
$g.DrawEllipse($penRing, 14, 14, 228, 228)

$penCyan = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(240, 6, 182, 212)), 4
$g.DrawEllipse($penCyan, 18, 18, 220, 220)

# Apex Triangle / Shield
$pt1 = New-Object System.Drawing.Point 128, 46
$pt2 = New-Object System.Drawing.Point 204, 182
$pt3 = New-Object System.Drawing.Point 52, 182
[System.Drawing.Point[]]$points = @($pt1, $pt2, $pt3)

$emblemBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList $pt1, (New-Object System.Drawing.Point 128, 182), ([System.Drawing.Color]::FromArgb(255, 99, 102, 241)), ([System.Drawing.Color]::FromArgb(255, 6, 182, 212))
$g.FillPolygon($emblemBrush, $points)

# White Lightning Core
$b1 = New-Object System.Drawing.Point 132, 72
$b2 = New-Object System.Drawing.Point 106, 126
$b3 = New-Object System.Drawing.Point 130, 126
$b4 = New-Object System.Drawing.Point 122, 166
$b5 = New-Object System.Drawing.Point 152, 114
$b6 = New-Object System.Drawing.Point 128, 114
[System.Drawing.Point[]]$boltPoints = @($b1, $b2, $b3, $b4, $b5, $b6)

$boltBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g.FillPolygon($boltBrush, $boltPoints)

$bmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Convert PNG to authentic Windows ICO file
$pngBytes = [System.IO.File]::ReadAllBytes($pngPath)
$icoStream = [System.IO.File]::Create($iconPath)
$bw = New-Object System.IO.BinaryWriter $icoStream

$bw.Write([uint16]0)
$bw.Write([uint16]1)
$bw.Write([uint16]1)

$bw.Write([byte]0)
$bw.Write([byte]0)
$bw.Write([byte]0)
$bw.Write([byte]0)
$bw.Write([uint16]1)
$bw.Write([uint16]32)
$bw.Write([uint32]$pngBytes.Length)
$bw.Write([uint32]22)

$bw.Write($pngBytes)
$bw.Flush()
$icoStream.Close()

$g.Dispose()
$bmp.Dispose()

Write-Output "ICO successfully generated: $(Test-Path $iconPath) [Size: $([math]::Round((Get-Item $iconPath).Length / 1KB, 1)) KB]"
