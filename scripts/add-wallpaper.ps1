# Copy pictures from this computer to the launcher's wallpaper list on the TV. Then on the TV: hold OK on the
# Settings pill > Launcher settings > Wallpaper, and pick one ("None" = black).
# Usage:  $env:TV_HOST='<tv ip>'; .\scripts\add-wallpaper.ps1 C:\Photos\beach.jpg [more.jpg ...]
param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]]$Pictures)
if (-not $env:TV_HOST) { throw 'set $env:TV_HOST to the TV IP first' }
$up = Join-Path (Split-Path $PSScriptRoot) 'cleanyourtv'
$py = "$up\tools\venv\Scripts\python.exe"
$dir = '/sdcard/Android/data/com.gathin.tvhome/files/wallpapers'
& $py "$up\tools\tv.py" "mkdir -p $dir"
foreach ($pic in $Pictures) {
    # Spaces in a name break the shell commands on the TV.
    $name = (Split-Path $pic -Leaf) -replace '[^A-Za-z0-9._-]', '_'
    & $py "$up\tools\b64push.py" $pic "$dir/$name"
}
