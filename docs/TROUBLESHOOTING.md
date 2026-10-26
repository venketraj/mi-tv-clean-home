# Troubleshooting (seen on this TV)

Upstream's [docs/TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)
covers far more; these are the ones that came up here.

**`could not reach <ip>:5555 (timed out)`**: the TV was in standby, or the PC had hopped onto another Wi-Fi
(a phone hotspot). `ipconfig` should show the same subnet as the TV. Wake the TV and retry.

**Screenshot is 0 bytes**: Live TV and HDMI can't be captured; that's the TV, not a fault. Check what's on
screen with `tv "dumpsys activity activities | grep mResumedActivity"`.

**A photo shows at power-on or behind Settings**: that's Android's system wallpaper. Run
`scripts\set-system-wallpaper.ps1` (black) or pass your own picture.

**Settings opens over a black/wallpaper background instead of the HDMI picture**: Android TV's Settings panel
always draws over the system wallpaper. For picture/sound while watching, use the remote's menu (≡) button.

**Wi-Fi pill says "Wi-Fi", not the network name**: Location is off. `tv 'settings put secure location_mode 3'`.

**Holding OK from ADB**: `input keyevent --longpress` is not seen as a hold by the launcher. Send the remote's
raw key instead (`Xiaomi RC` is `/dev/input/event3` here, OK = `KEY_SELECT` 353):
`tv 'sendevent /dev/input/event3 1 353 1; sendevent /dev/input/event3 0 0 0; sleep 1.2; sendevent /dev/input/event3 1 353 0; sendevent /dev/input/event3 0 0 0'`.

**Home is black / the old launcher is back after a restore**: `tv 'pm enable --user 0 com.google.android.tvlauncher'`,
then `tv 'cmd package set-home-activity --user 0 com.google.android.tvlauncher/.MainActivity'`.

**Never** start factory/test packages (`*factory*`, `*fac.menu*`) to see what they do, and never disable core
Android packages; upstream's `disable.ps1` refuses those lists for a reason.
