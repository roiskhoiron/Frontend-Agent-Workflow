# Masukan desain (prototipe dari workflow UI/UX)

Acuan desain tiket Frontend web adalah **prototipe** dari workflow UI/UX, bukan gambar mockup. Prototipe ada di repo desain tersendiri (`<proyek>-design`) dan terbit di GitHub Pages.

## Yang dirujuk tiket
| Yang dirujuk | Bentuk | Dipakai oleh |
|---|---|---|
| **Alamat tiap state** | `https://<org>.github.io/<repo-desain>/prototypes/<KODE>/<layar>.html?state=<state>` (daftar layar + state: `prototypes/<KODE>/`) | Planner, Coder, QA |
| **Halaman handover** | Tujuan, perilaku, token yang dipakai, tautan tiap state, catatan per platform (HTML di `docs/` repo desain, terbit bersama prototipe) | Planner, Coder |
| **Token hasil bangun** | CSS custom properties dari Style Dictionary: `build/css/tokens.css` di repo desain | Coder |

State umum: `kosong`, `memuat`, `berhasil`, `gagal`, `offline`, ditambah state khas tiket. Sebelum PR desain di-merge, prototipe ada di `preview/<KODE>/`; setelah merge alamat tetapnya `prototypes/<KODE>/`. Acuan tiket memakai alamat tetap; alamat `preview/` hanya boleh bila user setuju (dicatat di rencana).

## Tiga aturan
1. **Kode prototipe tidak disalin ke produk.** Prototipe ditulis tanpa framework dan tanpa tes. Layar ditulis ulang di framework proyek, dengan prototipe sebagai rujukan perilaku dan tampilan.
2. **Yang dipakai langsung hanya token.** `build/css/tokens.css` diambil dari repo desain (ref tercatat), sehingga warna dan ukuran di produk sama dengan prototipe. Kode produk memakai `var(--token)`, bukan nilai warna/ukuran yang ditulis langsung.
3. **QA membandingkan halaman dengan alamat state yang sama** di prototipe, satu state demi satu state, di tiap ukuran layar.

## Memory project (`rules.md` → Isi memory project, kunci "Repo desain")
| Isian | Contoh |
|---|---|
| Repo desain | `github.com/<org>/<proyek>-design` + checkout lokal (sejajar repo kode) |
| Alamat GitHub Pages | `https://<org>.github.io/<proyek>-design/` |
| Tujuan berkas token di repo kode | mis. `src/styles/tokens.css` (dicari dulu: berkas yang sudah memuat `--` custom properties dari Style Dictionary) |

Belum ada → cari dulu (link prototipe di tiket, README repo kode), tanya user sekali, simpan. Project yang belum memakai workflow UI/UX → pakai mockup/gambar di tiket seperti biasa, dan tiket UI paling tinggi **Layak dengan catatan**.

## Cara memakai
- **Sinkron:** `git -C <checkout repo desain> pull --ff-only`; catat hash. Daftar state tiket dari `prototypes/<KODE>/index.html` (atau halaman handover).
- **Sinkron token** (Coder, di worktree tiket): salin `build/css/tokens.css` dari ref repo desain yang tercatat ke tujuan berkas token, lalu commit sendiri: `chore: <KODE> sinkron token desain <hash7>`. Tidak pernah mengedit berkas token dengan tangan; token kurang/salah → tanya SPV (perubahannya lewat workflow UI/UX, bukan di repo kode).
- **Bandingkan per state** (QA): untuk tiap state × ukuran layar, buka alamat prototipe dan halaman produk dalam keadaan yang sama (data uji atau mock kontrak), screenshot keduanya dengan `page-shot.mjs` di viewport yang sama, lalu
  ```bash
  python3 "$FRONTEND_WORKFLOW_DIR/bin/compare-shot.py" halaman.png prototipe.png banding.png --threshold 0.02
  ```
  Exit 1 (beda di atas ambang) bukan otomatis gagal: QA melihat `banding.png` dan menandai beda yang nyata dengan kotak merah (`annotate.py`). Beda font/anti-aliasing kecil diabaikan; beda layout, warna token, teks, atau state yang hilang = TC gagal.
- State prototipe yang tidak bisa dicapai di produk (mis. butuh endpoint yang belum ada) → TC state itu **Tertahan** + alasan.
