# Copy launcher\config.xml into the upstream launcher, build it and install it on the TV as Home.
# Needs JDK 17 and the Android SDK (platform 34, build-tools 34.0.0); see docs\BUILD-ON-WINDOWS.md.
# Usage:  $env:TV_HOST='<tv ip>'; .\scripts\build-and-install.ps1
param([string]$TvHost = $env:TV_HOST)
$ErrorActionPreference = 'Stop'
if (-not $TvHost) { throw 'set $env:TV_HOST to the TV IP, or pass -TvHost' }
$root = Split-Path $PSScriptRoot
$up = Join-Path $root 'cleanyourtv'
Copy-Item "$root\launcher\config.xml" "$up\launcher\app\src\main\res\values\config.xml" -Force
$t = Join-Path $root 'toolchain'
if (Test-Path $t) {
    $env:JAVA_HOME = (Get-ChildItem $t -Directory | Where-Object Name -like 'jdk-17*' | Select-Object -First 1).FullName
    $env:ANDROID_HOME = "$t\sdk"
}
# Gradle fails with "Unable to establish loopback connection" when the temp path has spaces (Windows user names).
New-Item -ItemType Directory -Force C:\Users\Public\cytmp | Out-Null
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:\Users\Public\cytmp'
# Run it plainly: piping it through 2>&1 turns Java's "Picked up JAVA_TOOL_OPTIONS" note into a fatal error.
& "$up\launcher\build-and-install.ps1" -TvHost $TvHost
