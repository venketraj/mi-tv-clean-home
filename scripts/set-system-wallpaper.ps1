# Replace Android's own system wallpaper (shown at power-on before HDMI appears, and behind the TV Settings
# panel) with a picture, plain black by default. The ADB shell has no SET_WALLPAPER permission, so this hands the
# picture to Android's wallpaper cropper through MediaStore and presses its "Set wallpaper" button.
# Usage:  $env:TV_HOST='<tv ip>'; .\scripts\set-system-wallpaper.ps1 [C:\path\picture.png]
param([string]$Picture = '')
$ErrorActionPreference = 'Stop'
if (-not $env:TV_HOST) { throw 'set $env:TV_HOST to the TV IP first' }
$up = Join-Path (Split-Path $PSScriptRoot) 'cleanyourtv'
$py = "$up\tools\venv\Scripts\python.exe"
$tv = "$up\tools\tv.py"
if (-not $Picture) {
    Add-Type -AssemblyName System.Drawing
    $Picture = Join-Path $env:TEMP 'black.png'
    $bmp = New-Object Drawing.Bitmap 1280, 720
    [Drawing.Graphics]::FromImage($bmp).Clear([Drawing.Color]::Black)
    $bmp.Save($Picture, [Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
$ext = [IO.Path]::GetExtension($Picture).TrimStart('.').ToLower()
$remote = "/sdcard/system-wallpaper.$ext"
& $py "$up\tools\b64push.py" $Picture $remote
& $py $tv "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://$remote" | Out-Null
Start-Sleep 3
$row = & $py $tv 'content query --uri content://media/external/images/media --projection _id:_data' |
    Where-Object { $_ -like "*/system-wallpaper.$ext" } | Select-Object -Last 1
if ("$row" -notmatch '_id=(\d+)') { throw "MediaStore did not index $remote" }
$mime = if ($ext -eq 'png') { 'image/png' } else { 'image/jpeg' }
& $py $tv "am start --grant-read-uri-permission -a android.service.wallpaper.CROP_AND_SET_WALLPAPER -d content://media/external/images/media/$($Matches[1]) -t $mime -n com.android.wallpapercropper/.WallpaperCropActivity"
Start-Sleep 3
# Focus the "Set wallpaper" button at the top and press it.
& $py $tv 'input keyevent DPAD_UP'
& $py $tv 'input keyevent DPAD_CENTER'
Start-Sleep 2
& $py $tv "rm $remote"
& $py $tv "logcat -d -t 200 | grep -c 'bindWallpaperComponentLocked'"
Write-Host 'Done if the number above is 1 or more (Android reloaded the wallpaper).'
