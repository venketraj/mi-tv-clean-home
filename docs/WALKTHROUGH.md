# Walkthrough: what was done on the TV, in order

TV: Xiaomi MiTV-AXSO0 (codename `dangal`, Mi TV 4A Pro / 4C Pro), Android TV 9 (SDK 28), firmware `PI.6036`,
Amlogic. Done from a Windows 11 laptop on the same Wi-Fi, on 26 October 2026, following upstream's
[PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md).

`tv` below is `cleanyourtv\tools\venv\Scripts\python.exe cleanyourtv\tools\tv.py` with `$env:TV_HOST` set.

## 1. Connect

- Found the TV as the only LAN host with TCP 5555 open (`Get-NetNeighbor`, then a socket probe).
- `tv --probe` → `MiTV-AXSO0`, `dangal`, `PI.6036`, SDK 28, `ro.adb.secure=1`. Accepted "Allow USB debugging?"
  on the TV.
- Network was Wi-Fi (`dumpsys connectivity` → `Transports: WIFI`), nothing on USB (`host_connected=false`).

## 2. Back up

`pm list packages -f/-d/-s/-3`, `getprop`, `settings list global/secure/system`, `wm size`/`wm density`, and the
Home claimants (`cmd package query-activities … HOME` → `com.google.android.tvlauncher` and Settings'
`FallbackHome`; no setup wizard) went to `backup\<date>\`. `scripts\debloat.ps1` does the same.

## 3. Debloat in batches

Each list went through upstream `tools\disable.ps1` (it records a restore file in `~\.cleanyourtv\` and refuses
core Android packages), with a Home screenshot after every batch:

| Batch | What | Packages |
|---|---|---|
| 01 telemetry | Mi analytics, Xiaomi statistic, Google feedback, bug-report sender | 4 |
| 02 content-ads | PatchWall, web content, floating frame, TV recommendations, partner auto-installs | 6 |
| 03 xiaomi-services | TV Manager cleaner, handbook, legal screens | 3 |
| 04 cast-updates | Mi Cast, smart share, Miracast sink, Xiaomi updater (owner's choice) | 4 |
| 05 preloaded-apps | Mi Music, Play Games, Play Movies, Mi Gallery, YouTube Music, Netflix (owner's choice) | 6 |
| 06 mi-wallpaper | Mi screensaver `com.mitv.dream` (Google's Ambient screensaver kept) | 1 |

Kept on purpose: Google Assistant (`katniss`, `pumpkin`), Chromecast (`mediashell`), Play Store/Services, Live
TV (`com.android.tv`), the `droidlogic` TV inputs, keyboard and remote services.
After a reboot all 24 were still disabled; nothing came back.

## 4. Extras

- Private DNS → `dns.adguard-dns.com` (`private_dns_mode hostname`); YouTube still loads.
- Location on (`location_mode 3`, providers `gps,network`) so the launcher's Wi-Fi pill shows the SSID.

## 5. Launcher

- SDK 28 ≥ the launcher's `minSdk 26`; `pm install` accepted the APK (no verification block on this set).
- Built with JDK 17 + Android SDK 34 (see `BUILD-ON-WINDOWS.md`), installed by upstream
  `launcher\build-and-install.ps1`: APK pushed as base64 chunks with an md5 check, `pm install -r`,
  `set-home-activity`, launcher started and confirmed, *then* `com.google.android.tvlauncher` disabled.
- `config.xml` changes: see `launcher/config.diff`.
- Checked with screenshots: dock, Down/Up one row at a time, Up from the dock to the top bar, Inputs dropdown
  (HDMI1–3, AV, Live TV), reorder mode, the hold-OK Settings menu and the wallpaper picker.

## 6. System wallpaper

A family photo kept flashing at power-on (before HDMI comes up) and behind the TV Settings panel. That was
Android's system wallpaper (`dumpsys wallpaper` → `ImageWallpaper`), not the launcher's. The shell lacks
`SET_WALLPAPER` and the cropper app lacks storage access, so `scripts\set-system-wallpaper.ps1` registers the
picture in MediaStore and starts `com.android.wallpapercropper` with `--grant-read-uri-permission`, then presses
*Set wallpaper*.

## 7. Close up

USB debugging off, authorisations revoked, reboot, `tools\adb-closed.py <tv ip>` must say the port is closed.
