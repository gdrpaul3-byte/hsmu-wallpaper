# HSMU 강의실 바탕화면 사이트 (Codex / Claude Code)

정적 사이트다. 빌드 도구와 환경 변수는 없다. 학교 공용 Windows PC에서 클릭 한 번으로 현재 사용자 바탕화면을 수업중간피드백 QR 슬라이드로 바꾼다.

## 파일

| 경로 | 역할 |
| --- | --- |
| `index.html` | 한국어 안내 페이지. 미리보기, `set-wallpaper.bat` 다운로드 버튼, 이미지만 다운로드 링크, SmartScreen/복원 프로그램 안내. |
| `preview.png` | 페이지용 1920×1080 미리보기. |
| `hsmu-wallpaper.png` | 실제 바탕화면. 3840×2160, 16:9, 흰 배경. `.bat`가 이 파일을 내려받는다. |
| `set-wallpaper.bat` | **생성물. 직접 고치지 말 것.** ASCII·BOM 없음·CRLF. `scripts/build-bat.py`가 `scripts/set-wallpaper.ps1`을 UTF-16LE base64로 넣어 `powershell -EncodedCommand`로 실행. 관리자 권한 없이 현재 사용자에게만 적용. |
| `scripts/set-wallpaper.ps1` | 실제 바탕화면 설정 로직(원본). 수정 후 `python3 scripts/build-bat.py` 실행. |
| `vercel.json` | `/set-wallpaper.bat`에 `Content-Disposition: attachment`와 `application/octet-stream`. |
| `source/src.pptx` | 원본 슬라이드. 2번째 페이지가 바탕화면이다. |
| `scripts/render-wallpaper.sh` | PPTX → PNG 렌더. LibreOffice + `pdftoppm` 필요. |

## `set-wallpaper.bat` 동작

1. `powershell -EncodedCommand <base64>` 한 줄로 `scripts/set-wallpaper.ps1` 내용을 실행한다. 한글이 bat에 직접 들어가지 않아 코드 페이지 문제가 없다.
2. PowerShell은 TLS 1.2로 `https://hsmu-wallpaper.vercel.app/hsmu-wallpaper.png`를 `%USERPROFILE%\Pictures\hsmu-wallpaper.png`에 `Invoke-WebRequest`로 저장한다.
3. `HKCU\Control Panel\Desktop`의 `WallpaperStyle=6`(Fit, QR이 잘리지 않음), `TileWallpaper=0`.
4. `user32 SystemParametersInfo`(SPI_SETDESKWALLPAPER=20, flags=3)로 적용한다.
5. 한글 성공/실패 메시지를 출력하고, bat 쪽에서 `pause`한다.

프로덕션 도메인이 바뀌면 `$Url`(`scripts/set-wallpaper.ps1`)을 고친 뒤 `python3 scripts/build-bat.py`로 bat를 다시 만들어야 한다을 반드시 고친다. 상대 경로를 쓰면 다운로드에 실패한다.

## 이미지 교체

- 슬라이드를 바꿀 때: `source/src.pptx`를 교체한 다음 `./scripts/render-wallpaper.sh`를 실행한다. 2번째 페이지만 렌더한다. 슬라이드 순서가 바뀌면 스크립트의 `-f 2 -l 2`도 수정한다.
- PNG만 바꿀 때: `hsmu-wallpaper.png`(4K)와 `preview.png`(1080p)를 함께 교체한다.
- 렌더 후 QR이 읽히는지 확인한다. 2026-11-17 기준 QR은 `https://naver.me/GfrAkLb7` (네이버 폼 `https://form.naver.com/response/4XMkmOGlFqT`).

## 배포

- GitHub: `gdrpaul3-byte/hsmu-wallpaper` (public), 기본 브랜치 `main`.
- Vercel 팀: `gdrpaul3-s-projects` (id `team_6FE7loXYwCjfQKJCbC9K9Q1g`), 프로젝트 이름 `hsmu-wallpaper`.
- Git 연결이 되어 있으면 `main`에 푸시하면 프로덕션이 갱신된다.
- 박스의 Vercel CLI에는 토큰이 없다. CLI로 배포하지 말고, Git 푸시 또는 user-Vercel 커넥터의 `create_deployment`(target=`production`)를 쓴다.
- 이 사이트는 교내 여러 PC가 로그인 없이 열어야 한다. Vercel Deployment Protection(Vercel Authentication)을 켜 두지 않는다.
- 배포 후 `https://hsmu-wallpaper.vercel.app/`, `/hsmu-wallpaper.png`, `/set-wallpaper.bat`가 200인지 확인한다. `.bat` 응답에 `Content-Disposition: attachment`가 있어야 한다.

변경을 하면 이 파일과 README에 주소·슬라이드·QR 내용처럼 달라진 점을 짧게 남긴다.

## 변경 기록
- 2026-11-17: 첫 버전(자기 추출 방식) 실제 PC에서 실패. 원인: (1) UTF-8 BOM 때문에 첫 줄 `@echo off`가 깨져 명령이 화면에 노출됨, (2) PowerShell 한 줄 명령 안에도 `__PS1__` 문자열이 있어 `IndexOf`가 그 위치를 잡아 깨진 스크립트를 실행함. ASCII bat + `-EncodedCommand` 방식으로 교체.
