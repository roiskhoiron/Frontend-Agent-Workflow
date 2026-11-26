---
name: reproduce-browser
description: Skill internal workflow Frontend. Mereproduksi bug atau memeriksa perilaku halaman di browser (Playwright) pada ukuran layar dari tiket/matriks, dengan screenshot bertanda dari posisi elemen. Menggantikan /reproduce-device di Mobile. Dipakai /validate-tiket dan /audit-issue.
argument-hint: KODE-atau-slug
---
Reproduksi di browser untuk `$ARGUMENTS`. Baca: `browser.md`, `credentials.md`, `report-format.md` di `~/.agent-workflow/frontend-kit/skills/_shared/`.

## Langkah
1. **Versi/URL:** yang tertulis di tiket/permintaan. Kosong → URL staging dari memory project; tidak ada staging → server lokal dari ref `upstream/<protected>` di worktree yang ditugaskan (port dari `port-pick.sh`). Catat URL + hash commit (lokal) atau versi yang tampil.
2. **Ukuran layar:** dari tiket; tidak tertulis → desktop + ponsel (`browser.md` → Matriks).
3. **Akun:** butuh login → kunci akun (`lock.sh acquire account:<kunci> <owner>`), kredensial dibaca dari `.env.agent.local` saat dipakai.
4. Tulis langkah sebagai skrip Playwright sementara di `${TMPDIR:-/tmp}/<validate|audit>/<KODE-atau-slug>/repro.spec.mjs` (atau langkah `page-shot.mjs` bila cukup satu halaman); screenshot tiap langkah; console error dan request gagal (`page.on('console'|'requestfailed')`) dicatat.
5. Screenshot bertanda: posisi elemen → `*.boxes.json` → `annotate.py` (`browser.md` → Screenshot bertanda). Label = kode AC + penjelasan singkat.
5b. Bug UI dengan prototipe di Acuan: bandingkan juga dengan alamat state prototipe yang sama (`compare-shot.py`, `design-input.md`), supaya jelas mana yang menyimpang dari desain.
6. Tiga kali tidak tereproduksi di kondisi tiket → hasil **Tidak tereproduksi** + kondisi yang sudah dicoba (bukan "lulus").
7. Matikan server, lepas kunci port dan akun.

## Keluaran
`${TMPDIR:-/tmp}/<flow>/<KODE-atau-slug>/repro.md` + `*.png`: hasil (**Tereproduksi** / **Tidak tereproduksi** / **Tertahan** + alasan), URL + hash, browser + ukuran, langkah bernomor, console error, akun (nama kunci), data uji (awalan KODE).

## Tidak boleh
Data uji di production; akun tanpa kunci; menulis ke repo; menebak posisi kotak.
