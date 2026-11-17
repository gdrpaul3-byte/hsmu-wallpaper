# Builds set-wallpaper.bat from scripts/set-wallpaper.ps1.
# The .bat is pure ASCII (no BOM) and runs the script via powershell -EncodedCommand
# (base64 of UTF-16LE), so Korean text and cmd parsing can't break it.
import base64, pathlib
root = pathlib.Path(__file__).resolve().parent.parent
ps = (root/'scripts/set-wallpaper.ps1').read_text(encoding='utf-8')
enc = base64.b64encode(ps.encode('utf-16-le')).decode('ascii')
bat = "\r\n".join([
 "@echo off",
 "setlocal",
 "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand " + enc,
 "if errorlevel 1 (echo. & echo Failed to set the wallpaper.)",
 "echo.",
 "pause",
 ""])
assert len(bat) < 8000, len(bat)
(root/'set-wallpaper.bat').write_bytes(bat.encode('ascii'))
print('ok', len(bat))
