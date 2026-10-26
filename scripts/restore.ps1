# Undo everything: re-enable every package from lists\, give Home back to the stock Google TV launcher and
# switch Private DNS back to automatic. Usage:  $env:TV_HOST='<tv ip>'; .\scripts\restore.ps1
param([string]$TvHost = $env:TV_HOST)
$ErrorActionPreference = 'Stop'
if (-not $TvHost) { throw 'set $env:TV_HOST to the TV IP, or pass -TvHost' }
$env:TV_HOST = $TvHost
$root = Split-Path $PSScriptRoot
$up = Join-Path $root 'cleanyourtv'
$py = "$up\tools\venv\Scripts\python.exe"
$tv = "$up\tools\tv.py"
# Newest batch first; upstream restore.ps1 uses the record disable.ps1 left in ~\.cleanyourtv.
Get-ChildItem "$root\lists" -Filter *.txt | Sort-Object Name -Descending | ForEach-Object {
    & "$up\tools\restore.ps1" -TvHost $TvHost $_.FullName
}
& $py $tv 'pm enable --user 0 com.google.android.tvlauncher'
& $py $tv 'cmd package set-home-activity --user 0 com.google.android.tvlauncher/.MainActivity'
& $py $tv 'settings put global private_dns_mode opportunistic'
Write-Host "Restored. To remove the new launcher too:  & '$py' '$tv' 'pm uninstall com.gathin.tvhome'"
