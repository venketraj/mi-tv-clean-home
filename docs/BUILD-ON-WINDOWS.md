# Building the launcher on Windows without Android Studio

`scripts\build-and-install.ps1` looks for a `toolchain\` folder in the repo root (git-ignored). About 600 MB.

```powershell
$t = "$PWD\toolchain"; New-Item -ItemType Directory -Force "$t\dl" | Out-Null

# 1. Temurin JDK 17 (newer JDKs are too new for the project's Gradle 8.9)
curl.exe -L -o "$t\dl\jdk17.zip" https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse
Expand-Archive "$t\dl\jdk17.zip" $t
$env:JAVA_HOME = (Get-ChildItem $t -Directory | Where-Object Name -like 'jdk-17*').FullName

# 2. Android command-line tools (check the current file name on developer.android.com/studio#command-tools)
curl.exe -L -C - --retry 10 -o "$t\dl\clt.zip" https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip
Expand-Archive "$t\dl\clt.zip" "$t\sdk\cmdline-tools\tmp"
Move-Item "$t\sdk\cmdline-tools\tmp\cmdline-tools" "$t\sdk\cmdline-tools\latest"

# 3. Licences + platform 34 + build-tools 34. Piping "y" into sdkmanager does not work from PowerShell;
#    redirect stdin from a file instead.
Set-Content -Encoding ascii "$t\dl\yes.txt" (("y`r`n") * 12)
$sm = "$t\sdk\cmdline-tools\latest\bin\sdkmanager.bat"
Start-Process $sm -ArgumentList "--sdk_root=`"$t\sdk`"", '--licenses' -RedirectStandardInput "$t\dl\yes.txt" -NoNewWindow -Wait
Start-Process $sm -ArgumentList "--sdk_root=`"$t\sdk`"", '"platforms;android-34"', '"build-tools;34.0.0"' -RedirectStandardInput "$t\dl\yes.txt" -NoNewWindow -Wait
```

Verify the downloads: the JDK's SHA-256 is in `https://api.adoptium.net/v3/assets/latest/17/hotspot?os=windows&architecture=x64&image_type=jdk`
(`binary.package.checksum`), the command-line tools' SHA-1 in `https://dl.google.com/android/repository/repository2-3.xml`.

Then `.\scripts\build-and-install.ps1`. Gradle 8.9 downloads itself on the first run.

## Two Windows gotchas

- **`Unable to establish loopback connection`** from Gradle: Java's socket pair lands in a temp folder whose path
  has a space (`C:\Users\First Last\…`). The script sets
  `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\Users\Public\cytmp`. The path itself must not contain spaces.
- **Don't pipe the script through `2>&1` / `*>&1`**: Java prints "Picked up JAVA_TOOL_OPTIONS" on stderr, and
  Windows PowerShell 5.1 turns that into a terminating error under `$ErrorActionPreference = 'Stop'`.

The APK is about 535 KB.
