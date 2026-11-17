#!/usr/bin/env bash
# source/src.pptx 의 2번째 슬라이드를 바탕화면 PNG로 렌더한다.
# 사용: ./scripts/render-wallpaper.sh
# 필요 도구: LibreOffice(soffice), poppler(pdftoppm)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/source/src.pptx"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ ! -f "$SRC" ]]; then
  echo "missing $SRC" >&2
  exit 1
fi

soffice --headless --convert-to pdf --outdir "$TMP" "$SRC"
PDF="$(ls "$TMP"/*.pdf | head -1)"

# 3840x2160 (16:9). 강의실 4K/FHD 모두에서 QR이 선명하도록 고해상도로 뽑는다.
pdftoppm -f 2 -l 2 -png -scale-to-x 3840 -scale-to-y 2160 "$PDF" "$TMP/wall"
pdftoppm -f 2 -l 2 -png -scale-to-x 1920 -scale-to-y 1080 "$PDF" "$TMP/prev"
cp "$TMP/wall-2.png" "$ROOT/hsmu-wallpaper.png"
cp "$TMP/prev-2.png" "$ROOT/preview.png"
echo "wrote $ROOT/hsmu-wallpaper.png and $ROOT/preview.png"

python3 - "$ROOT/hsmu-wallpaper.png" <<'PY' || true
import sys
try:
    import cv2
except ImportError:
    sys.exit(0)
img = cv2.imread(sys.argv[1])
data, _, _ = cv2.QRCodeDetector().detectAndDecode(img)
print("QR:", data or "(decode failed)")
PY
