@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "HSMU_SCRIPT=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:HSMU_SCRIPT; $out=Join-Path $env:TEMP 'hsmu-set-wallpaper.ps1'; $t=Get-Content -LiteralPath $p -Raw -Encoding UTF8; $m='__PS1__'; $i=$t.IndexOf($m); if($i -lt 0){ throw 'script marker not found' }; $t=$t.Substring($i+$m.Length).TrimStart([char]13,[char]10); Set-Content -LiteralPath $out -Value $t -Encoding UTF8; & $out; exit $LASTEXITCODE"
set "ERR=%ERRORLEVEL%"
del /q "%TEMP%\hsmu-set-wallpaper.ps1" 2>nul
echo.
if not "%ERR%"=="0" (
  echo Failed to set the wallpaper.
  pause
  exit /b %ERR%
)
pause
exit /b 0

__PS1__
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Production URL of the wallpaper PNG. Update this if the Vercel domain changes.
$Url = 'https://hsmu-wallpaper.vercel.app/hsmu-wallpaper.png'
$Dest = Join-Path $env:USERPROFILE 'Pictures\hsmu-wallpaper.png'

try {
  $dir = Split-Path -Parent $Dest
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
  if (-not (Test-Path -LiteralPath $Dest) -or ((Get-Item -LiteralPath $Dest).Length -lt 1000)) {
    throw 'download failed'
  }

  # 6 = Fit (이미지 전체가 보이도록. QR이 잘리지 않음). 10 = Fill (잘릴 수 있음)
  Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '6'
  Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'

  Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class HsmuWallpaper {
  [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
  public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
  # SPI_SETDESKWALLPAPER = 20, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 3
  $ok = [HsmuWallpaper]::SystemParametersInfo(20, 0, $Dest, 3)
  if ($ok -eq 0) { throw 'SystemParametersInfo failed' }

  Write-Host ''
  Write-Host '바탕화면이 설정되었습니다.'
  Write-Host '파일이 저장된 위치:' $Dest
  exit 0
} catch {
  Write-Host ''
  Write-Host '설정에 실패했습니다.'
  Write-Host $_.Exception.Message
  Write-Host '사이트에서 이미지를 직접 받은 뒤, 바탕 화면에서 마우스 오른쪽 버튼 > 개인 설정으로 지정해 주세요.'
  exit 1
}
