# Browser, port, dan screenshot

Menggantikan "device" di workflow Mobile. Browser jauh lebih ringan daripada emulator, jadi **tidak ada antrean browser**: tiap agen boleh membuka browser Playwright sendiri. Yang dibagi dan dikunci hanya **port dev server** dan **akun uji**.

## Alat
| Alat | Dipakai untuk | Catatan |
|---|---|---|
| Playwright (`@playwright/test` milik project) | uji alur layar per TC, regresi, smoke live | Jalankan lewat package manager project (`npx playwright test`, `pnpm exec playwright test`), `--trace off` kecuali sedang debug |
| `$FRONTEND_WORKFLOW_DIR/bin/page-shot.mjs` | screenshot satu halaman + posisi elemen (`*.boxes.json`) | Tanpa project Playwright pun jalan (pakai Playwright global) |
| `$FRONTEND_WORKFLOW_DIR/bin/annotate.py` | kotak merah + label di screenshot | Masukan = `*.boxes.json` dari `page-shot.mjs` atau dari spec Playwright |
| Browser tertanam Orca | lihat cepat halaman bersama user, reproduksi manual | Bukan bukti uji; bukti tetap screenshot Playwright |
| axe-core (`@axe-core/playwright` milik project, atau `npx @axe-core/cli`) | cek aksesibilitas | Lihat "Aksesibilitas" |
| Schemathesis, Pact | API dan kontrak | Sama dengan Mobile; lihat `/check-contract` |

Playwright belum ada di project → pakai `page-shot.mjs` untuk reproduksi/screenshot, dan tanya user sebelum menambah `@playwright/test` ke project (perubahan dependensi masuk rencana tiket).

## Matriks browser dan ukuran layar
Dari memory project (`rules.md` → Isi memory project). Belum ada → saran default lalu tanya sekali:

| Nama | Viewport | Browser |
|---|---|---|
| desktop | 1440×900 | Chromium |
| tablet | 768×1024 | Chromium |
| ponsel | 390×844 | Chromium (emulasi `isMobile`, `hasTouch`) |

Browser tambahan (Firefox, WebKit) hanya bila tercatat wajib. Tiket menyebut browser/ukuran tertentu → itu yang diuji, ditambah desktop + ponsel.

## Port dev server
- Satu port per worktree/agen: `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/port-pick.sh" <owner>` (owner `<KODE>-<peran><n>`), cetak port lalu kunci `port:<n>`.
- Jalankan server di background dengan port itu: mis. `npm run dev -- --port <n>`, `next dev -p <n>`, `vite preview --port <n> --strictPort`. Log ke `${TMPDIR:-/tmp}/qa/<KODE>/server-<n>.log`.
- Env API server lokal diarahkan lewat variabel env project (memory project), diisi saat menjalankan perintah, tidak ditulis ke file yang ter-track.
- Selesai: matikan proses server itu (pid dari `$!`), lalu `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/lock.sh" release port:<n> <owner>`.
- Mock server dari kontrak (`/mock-api`) juga memakai port dari `port-pick.sh`.

## Screenshot bertanda
Kotak merah diambil dari **posisi elemen di halaman**, tidak ditebak.
```bash
cat > ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.targets.json <<'EOF'
[{"selector": "[data-testid=save]", "label": "AC1 tombol Simpan aktif"}]
EOF
node "$FRONTEND_WORKFLOW_DIR/bin/page-shot.mjs" --url http://localhost:4101/form --viewport 390x844 \
  --out ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.raw.png --targets ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.targets.json
python3 "$FRONTEND_WORKFLOW_DIR/bin/annotate.py" ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.raw.png \
  ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.raw.boxes.json ${TMPDIR:-/tmp}/qa/PROJ-1/TC1-01.png
```
- `page-shot.mjs` exit 1 = ada selector tidak ditemukan (dicatat di laporan, bukan ditebak); exit 3 = Playwright tidak ada atau halaman gagal dibuka.
- Di spec Playwright project: ambil `locator.boundingBox()` lalu tulis JSON yang sama (`x`,`y`,`w`,`h`,`label`), screenshot `page.screenshot()`, lalu `annotate.py`.
- Nama file urut: `TC1-desktop-01.png`, `TC1-ponsel-01.png`. Satu hal penting per kotak.
- Semua file kerja di `${TMPDIR:-/tmp}/{validate,qa,audit}/...`, tidak di repo (kecuali spec Playwright yang memang ditambahkan ke suite).

## Bandingkan dengan mockup
Tiap layar × ukuran layar: layout, spacing, warna/tipografi, teks, state kosong/loading/error/disabled, hover/focus, mode gelap (bila didukung), teks panjang/overflow. Sumber mockup dari Acuan tiket (Figma, gambar di tiket). Figma bisa dibuka lewat MCP/alat yang tersedia di sesi; tidak bisa → minta ekspor gambar ke user. Beda → kotak merah + label `beda: <apa>`.

## Aksesibilitas
- Jalankan axe di tiap halaman/state yang disentuh tiket, di desktop dan ponsel: `@axe-core/playwright` di spec project (`new AxeBuilder({ page }).analyze()`), atau `npx @axe-core/cli <url>` bila project belum punya.
- **Gerbang:** pelanggaran `critical`/`serious` yang muncul di elemen yang disentuh tiket = TC gagal. Pelanggaran lama di luar area tiket dicatat di laporan sebagai temuan, tidak memblokir.
- Tambahan manual singkat: navigasi keyboard (Tab urut, fokus terlihat, Esc menutup dialog), label form, teks alternatif gambar, kontras teks di mockup.

## Responsif
- Tiap TC UI dijalankan di semua ukuran layar dari matriks. Tidak ada scroll horizontal di ponsel, target sentuh ≥ 44 px, teks tidak terpotong.
- Gagal di satu ukuran = TC gagal di ukuran itu (tabel TC × ukuran di laporan).

## Akun uji
Satu akun, satu agen, satu waktu: `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/lock.sh" acquire account:qa.user1 <owner>`; exit 1 = dipegang agen lain (nama pemegang tercetak) → pakai akun lain atau tunggu. Lepas setelah selesai. Detail kredensial di `credentials.md`.
