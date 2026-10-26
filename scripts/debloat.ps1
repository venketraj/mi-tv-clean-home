# Back up the TV, then disable each list in lists\ in order, with a screenshot after every batch.
# Packages are disabled for user 0, never uninstalled. Comment out any line in lists\ you want to keep first.
# Usage:  $env:TV_HOST='<tv ip>'; .\scripts\debloat.ps1
param([string]$TvHost = $env:TV_HOST)
$ErrorActionPreference = 'Stop'
if (-not $TvHost) { throw 'set $env:TV_HOST to the TV IP, or pass -TvHost' }
$env:TV_HOST = $TvHost
$root = Split-Path $PSScriptRoot
$up = Join-Path $root 'cleanyourtv'
$py = "$up\tools\venv\Scripts\python.exe"
$tv = "$up\tools\tv.py"

$b = Join-Path $root ('backup\' + (Get-Date -Format 'yyyyMMdd-HHmm'))
New-Item -ItemType Directory -Force $b, "$root\shots" | Out-Null
$cmds = [ordered]@{
    'packages-all.txt' = 'pm list packages -f'; 'packages-disabled.txt' = 'pm list packages -d'
    'getprop.txt' = 'getprop'; 'settings-global.txt' = 'settings list global'
    'settings-secure.txt' = 'settings list secure'; 'settings-system.txt' = 'settings list system'
}
foreach ($k in $cmds.Keys) { & $py $tv $cmds[$k] | Out-File -Encoding utf8 "$b\$k" }
Write-Host "Backup in $b"

foreach ($list in Get-ChildItem "$root\lists" -Filter *.txt | Sort-Object Name) {
    & "$up\tools\disable.ps1" -TvHost $TvHost $list.FullName
    & $py $tv --screenshot "$root\shots\$($list.BaseName).png" HOME --wait 2
    Read-Host "Check shots\$($list.BaseName).png (Home still works?), Enter to continue, Ctrl+C to stop"
}
