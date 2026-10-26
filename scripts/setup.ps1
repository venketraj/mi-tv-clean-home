# One-time setup: clone the upstream cleanyourtv repo (pinned to the commit this setup was tested on) into
# .\cleanyourtv and install its ADB client (adb-shell) into a venv. No adb binary needed.
# Usage (from the repo root):  .\scripts\setup.ps1 [-Commit <sha>|latest]
param([string]$Commit = 'f592b6d2db0cfa0e28779660f25ff65386a5ff9b')
$ErrorActionPreference = 'Stop'
$up = Join-Path (Split-Path $PSScriptRoot) 'cleanyourtv'
if (-not (Test-Path $up)) { git clone https://github.com/Gathin23/cleanyourtv $up }
if ($Commit -ne 'latest') { git -C $up checkout -q $Commit }
if (-not (Test-Path "$up\tools\venv")) { python -m venv "$up\tools\venv" }
& "$up\tools\venv\Scripts\python.exe" -m pip install -q -r "$up\tools\requirements.txt"
Write-Host "Ready. Next:  `$env:TV_HOST='<tv ip>'; .\scripts\debloat.ps1"
