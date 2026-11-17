# 화성의과학대학교 강의실 바탕화면 설정

학교 Windows PC에서 사이트를 열고 **바탕화면으로 설정**을 누르면,
2026-2 학기 수업중간피드백 QR 코드 슬라이드가 현재 사용자 바탕화면으로 지정됩니다.

- 사이트: https://hsmu-wallpaper.vercel.app
- 저장소: https://github.com/gdrpaul3-byte/hsmu-wallpaper
- Vercel 팀: `gdrpaul3-s-projects` / 프로젝트 이름 `hsmu-wallpaper`

브라우저만으로는 Windows 바탕화면을 바꿀 수 없어서, 사이트는 이미지와 함께 설정용 `set-wallpaper.bat`를 내려 줍니다. 관리자 권한은 필요 없습니다.

## 사용 방법

1. 강의실 PC 브라우저에서 사이트를 연다.
2. **바탕화면으로 설정**을 눌러 `set-wallpaper.bat`를 받는다.
3. 받은 파일을 실행한다.
4. Windows 보호(SmartScreen) 경고가 뜨면 **추가 정보 → 실행**을 선택한다.

이미지만 받아 수동으로 지정하려면 **이미지만 다운로드**를 사용한다.

## 알아 둘 점

- 바탕화면은 ‘맞춤(Fit, WallpaperStyle=6)’으로 맞춰 QR 코드가 잘리지 않게 한다.
- 디프리즈·복원카드처럼 재시작 시 원상 복구하는 프로그램이 있는 PC는, 재부팅 후 이전 바탕화면으로 돌아갈 수 있다. 그런 경우에는 복원 제외 설정 후 다시 적용하거나, 수업 시작 시 한 번씩 실행한다.
- Chrome/Edge가 `.bat` 다운로드를 위험하다고 막을 수 있다. 그 경우 보관(유지)을 누른 뒤 실행한다.

## 이미지 바꾸기

1. `source/src.pptx`를 새 자료로 교체한다. 바탕화면으로 쓸 슬라이드는 **2번째 페이지**, 비율은 16:9를 권장한다.
2. `./scripts/render-wallpaper.sh`를 실행한다. `hsmu-wallpaper.png`(3840×2160)와 `preview.png`(1920×1080)가 다시 만들어진다.
3. QR이 읽히는지 스크립트 출력(또는 이미지 확인)을 본다.
4. 커밋한 뒤 `main`에 푸시하면 Vercel이 자동 배포한다.

이미지만 바로 바꿀 때는 `hsmu-wallpaper.png`와 `preview.png`를 교체해도 된다.

프로덕션 주소가 바뀌면 `scripts/set-wallpaper.ps1`의 `$Url`을 고치고 `python3 scripts/build-bat.py`로 `set-wallpaper.bat`를 다시 만든다(bat는 직접 수정 금지).

자세한 파일 설명과 배포 절차는 `AGENTS.md`를 본다.
