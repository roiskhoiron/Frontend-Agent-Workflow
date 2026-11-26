#!/usr/bin/env python3
"""Usage: compare-shot.py <halaman.png> <prototipe.png> <out.png> [--threshold 0.02]
Compares a screenshot of the product page with a screenshot of the prototype at the SAME state
URL and viewport (design-input.md). Writes <out.png>: page | prototype | difference (changed
pixels in red over a faded page). Prints one JSON line:
  {"diff_ratio": 0.0123, "page": [w, h], "prototype": [w, h], "compared": [w, h]}
Images of different size are compared on the shared top-left area (sizes are reported).
The ratio is a hint for QA, not a verdict: fonts and anti-aliasing differ slightly.
Exit: 0 diff_ratio <= threshold; 1 above threshold; 2 usage / unreadable image."""
import json, sys
from PIL import Image, ImageChops

def die(msg):
    print("compare-shot: " + msg, file=sys.stderr)
    sys.exit(2)

def main():
    args, thr = [], 0.02
    it = iter(sys.argv[1:])
    for a in it:
        if a == "--threshold":
            try:
                thr = float(next(it))
            except (StopIteration, ValueError):
                die("--threshold butuh angka 0..1")
        else:
            args.append(a)
    if len(args) != 3:
        die("usage: compare-shot.py <halaman.png> <prototipe.png> <out.png> [--threshold 0.02]")
    try:
        a = Image.open(args[0]).convert("RGB")
        b = Image.open(args[1]).convert("RGB")
    except Exception as e:
        die(f"gambar tidak bisa dibaca: {e!r}")
    w, h = min(a.width, b.width), min(a.height, b.height)
    if w == 0 or h == 0:
        die("gambar kosong")
    ca, cb = a.crop((0, 0, w, h)), b.crop((0, 0, w, h))
    # a pixel counts as different when the brightness of the difference exceeds 24 (ignores anti-aliasing noise)
    mask = ImageChops.difference(ca, cb).convert("L").point(lambda v: 255 if v > 24 else 0)
    changed = mask.histogram()[255]
    ratio = changed / float(w * h)
    faded = Image.blend(ca, Image.new("RGB", (w, h), (255, 255, 255)), 0.6)
    faded.paste(Image.new("RGB", (w, h), (224, 32, 32)), (0, 0), mask)
    gap = 16
    out = Image.new("RGB", (a.width + b.width + w + 2 * gap, max(a.height, b.height)), (255, 255, 255))
    out.paste(a, (0, 0)); out.paste(b, (a.width + gap, 0)); out.paste(faded, (a.width + b.width + 2 * gap, 0))
    out.save(args[2])
    print(json.dumps({"diff_ratio": round(ratio, 4), "page": [a.width, a.height],
                      "prototype": [b.width, b.height], "compared": [w, h]}))
    sys.exit(0 if ratio <= thr else 1)

main()
