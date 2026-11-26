#!/usr/bin/env bash
# bin/compare-shot.py: halaman vs prototipe di state + viewport yang sama.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
C="$REPO/bin/compare-shot.py"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
python3 - "$T" <<'PY'
import sys
from PIL import Image, ImageDraw
d = sys.argv[1]
a = Image.new("RGB", (200, 100), "white"); ImageDraw.Draw(a).rectangle([10, 10, 60, 40], fill=(0, 90, 200))
a.save(f"{d}/a.png"); a.save(f"{d}/same.png")
b = a.copy(); ImageDraw.Draw(b).rectangle([100, 10, 190, 90], fill=(200, 0, 0)); b.save(f"{d}/diff.png")
a.crop((0, 0, 200, 80)).save(f"{d}/short.png")
PY
assert_exit 0 "gambar sama -> 0" -- python3 "$C" "$T/a.png" "$T/same.png" "$T/o1.png"
out=$(python3 "$C" "$T/a.png" "$T/same.png" "$T/o1.png")
assert_eq 0.0 "$(echo "$out" | jq .diff_ratio)" "diff_ratio 0"
assert_eq yes "$([ -s "$T/o1.png" ] && echo yes)" "gambar banding ditulis"
assert_eq 632 "$(python3 -c "from PIL import Image;print(Image.open('$T/o1.png').width)")" "banding = halaman | prototipe | beda"
assert_exit 1 "beda besar -> 1" -- python3 "$C" "$T/a.png" "$T/diff.png" "$T/o2.png"
assert_exit 0 "ambang dinaikkan -> 0" -- python3 "$C" "$T/a.png" "$T/diff.png" "$T/o2.png" --threshold 0.9
assert_eq "[200,80]" "$(python3 "$C" "$T/a.png" "$T/short.png" "$T/o3.png" | jq -c .compared)" "ukuran beda: area bersama"
assert_exit 2 "argumen kurang -> 2" -- python3 "$C" "$T/a.png"
assert_exit 2 "gambar rusak -> 2" -- python3 "$C" "$T/a.png" "$T/tidak-ada.png" "$T/o4.png"
assert_exit 2 "ambang bukan angka -> 2" -- python3 "$C" "$T/a.png" "$T/same.png" "$T/o5.png" --threshold x
echo "compare_shot_test FAILS=$FAILS"; exit $FAILS
