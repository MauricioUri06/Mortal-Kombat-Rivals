param([string]$Workspace = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class SpriteImport {
    public static Bitmap Frame(Bitmap atlas, int left, int top, int right, int bottom,
                               int anchor, int baseline, int width, int height, int ox, int oy) {
        Bitmap result = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(result)) {
            g.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
            g.DrawImage(atlas, new Rectangle(ox + left - anchor, oy + top - baseline,
                        right - left, bottom - top),
                        new Rectangle(left, top, right - left, bottom - top), GraphicsUnit.Pixel);
        }
        return result;
    }
}
'@
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'atlas_manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$atlases = @{}
try {
    foreach ($entry in $manifest) {
        $spriteDir = Join-Path $Workspace ('sprites\' + $entry.name)
        for ($index = 0; $index -lt $entry.frames.Count; $index++) {
            if ($entry.primitive -eq 'rectangle') {
                $frame = [System.Drawing.Bitmap]::new($entry.width, $entry.height)
                $graphics = [System.Drawing.Graphics]::FromImage($frame)
                $graphics.FillRectangle([System.Drawing.Brushes]::White,
                    [int]$entry.bounds[0], [int]$entry.bounds[1],
                    [int]($entry.bounds[2] - $entry.bounds[0] + 1),
                    [int]($entry.bounds[3] - $entry.bounds[1] + 1))
                $graphics.Dispose()
            } else {
                $source = Join-Path $Workspace $entry.source
                if (!$atlases.ContainsKey($source)) { $atlases[$source] = [System.Drawing.Bitmap]::new($source) }
                $atlas = $atlases[$source]
                $col = [int]$entry.columns[$index]
                $row = $entry.row
                if ($null -ne $row.edges) {
                    $left = [int]$row.edges[$col]; $right = [int]$row.edges[$col + 1]
                } else {
                    $left = [int][Math]::Floor($col * $atlas.Width / 8)
                    $right = [int][Math]::Floor(($col + 1) * $atlas.Width / 8)
                }
                $anchor = [int][Math]::Round($row.anchor + $row.pitch * $col)
                $frame = [SpriteImport]::Frame($atlas, $left, [int]$row.top, $right, [int]$row.bottom,
                    $anchor, [int]$row.baseline, [int]$entry.width, [int]$entry.height,
                    [int]$entry.origin[0], [int]$entry.origin[1])
            }
            $id = $entry.frames[$index]
            $layerDir = Join-Path $spriteDir ('layers\' + $id)
            [System.IO.Directory]::CreateDirectory($layerDir) | Out-Null
            $frame.Save((Join-Path $spriteDir ($id + '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
            $frame.Save((Join-Path $layerDir ($entry.layer + '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
            $frame.Dispose()
        }
    }
} finally {
    foreach ($atlas in $atlases.Values) { $atlas.Dispose() }
}
Write-Output ('Imported ' + $manifest.Count + ' sprites with original transparent atlas pixels.')
