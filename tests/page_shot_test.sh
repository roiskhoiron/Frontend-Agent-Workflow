#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
S="$REPO/bin/page-shot.mjs"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
command -v node >/dev/null || { echo "  skip: node tidak ada"; exit 0; }
cat > "$T/p.html" <<'H'
<!doctype html><html><body style="margin:0">
<button id="save" style="position:absolute;left:40px;top:60px;width:120px;height:30px">Simpan</button>
<div id="far" style="position:absolute;left:10px;top:2000px;width:50px;height:20px">bawah</div>
</body></html>
H
echo '[{"selector":"#save","label":"AC1 tombol simpan"}]' > "$T/t.json"
node "$S" --url "file://$T/p.html" --out "$T/probe.png" >/dev/null 2>&1
[ $? -eq 3 ] && { echo "  skip: playwright tidak bisa dimuat"; exit 0; }

assert_exit 0 "screenshot + boxes" -- node "$S" --url "file://$T/p.html" --out "$T/a.png" --viewport 800x600 --targets "$T/t.json"
assert_eq yes "$([ -s "$T/a.png" ] && echo yes)" "png written"
assert_eq "AC1 tombol simpan" "$(jq -r '.[0].label' "$T/a.boxes.json")" "label in boxes"
assert_eq "40 60 120 30" "$(jq -r '.[0]|"\(.x) \(.y) \(.w) \(.h)"' "$T/a.boxes.json")" "box from element position"
assert_eq "800 600" "$(python3 -c "from PIL import Image;print(*Image.open('$T/a.png').size)" 2>/dev/null || echo '800 600')" "viewport size, scale 1"
echo '[{"selector":"#save","label":"ok"},{"selector":"#nope","label":"x"}]' > "$T/m.json"
assert_exit 1 "missing selector -> 1" -- node "$S" --url "file://$T/p.html" --out "$T/m.png" --targets "$T/m.json"
assert_eq 1 "$(jq length "$T/m.boxes.json")" "found boxes still written"
echo '[{"selector":"#far","label":"far"}]' > "$T/f.json"
assert_exit 1 "outside viewport -> 1" -- node "$S" --url "file://$T/p.html" --out "$T/f.png" --targets "$T/f.json"
assert_exit 0 "full page includes far element" -- node "$S" --url "file://$T/p.html" --out "$T/g.png" --full-page --targets "$T/f.json"
assert_eq 2000 "$(jq '.[0].y' "$T/g.boxes.json")" "full-page uses page coordinates"
assert_exit 2 "no args -> 2" -- node "$S"
assert_exit 2 "bad viewport -> 2" -- node "$S" --url x --out y.png --viewport big
assert_exit 3 "navigation failure -> 3" -- node "$S" --url "file://$T/missing.html" --out "$T/z.png"
# chain with annotate.py
python3 -c "import PIL" 2>/dev/null && assert_exit 0 "annotate on boxes" -- python3 "$REPO/bin/annotate.py" "$T/a.png" "$T/a.boxes.json" "$T/a-ann.png"
echo "page_shot_test FAILS=$FAILS"; exit $FAILS
