---
name: test-browser
description: Skill internal workflow Frontend. Prosedur QA - menjalankan server di port terkunci, test case Playwright di tiap ukuran layar dan browser dari matriks, membandingkan tiap state dengan prototipe, uji per server, regresi area terdampak, lalu menulis report.md + screenshot bertanda. Menggantikan /test-device di Mobile. Dipakai /develop-tiket langkah 5.
argument-hint: "KODE <checkout yang diuji> [server: dev,staging]"
---
Uji `$ARGUMENTS`. Baca: `browser.md`, `design-input.md`, `credentials.md`, `report-format.md` (Laporan uji).

## Langkah
1. **Matriks browser** dari memory project (belum ada → saran default `browser.md`, tanya sekali lewat SPV, simpan).
2. **Server lokal:** port dari `port-pick.sh` (owner `<KODE>-qa<n>`); `--batch` = checkout domain (branch batch) dengan **build produksi + preview** sekali untuk semua tiket; `--separate` = worktree tiket. API diarahkan ke server env yang diuji lewat variabel env project; endpoint belum ada → mock kontrak dan TC server itu **Tertahan**.
3. **Akun:** kunci per akun; login sekali per akun → `storageState` di `${TMPDIR:-/tmp}/qa/<KODE>/`.
4. **TC UI** dari rencana: spec Playwright (spec project bila ada; spec sementara di `${TMPDIR:-/tmp}/qa/<KODE>/`) dijalankan per ukuran layar × browser; screenshot tiap langkah, bertanda dari posisi elemen; console error dan request gagal dicatat (console error baru = temuan).
5. **Prototipe, state demi state** (`design-input.md`): untuk tiap alamat state di tugas × ukuran layar, bawa halaman produk ke state yang sama (data uji/mock), screenshot halaman dan prototipe di viewport sama, `compare-shot.py` → `banding-<layar>-<state>-<ukuran>.png`; periksa dan tandai beda nyata (`browser.md` → Bandingkan dengan prototipe), termasuk micro-interaction yang dilaporkan Coder. State tidak bisa dicapai → Tertahan + alasan.
6. **API/kontrak:** Schemathesis penuh hanya dev; staging/production method aman; Pact konsumen bila ada kontrak.
7. **Per server:** TC dijalankan untuk tiap server di rencana; tabel TC × server; Matriks env diperbarui bila hasil berbeda.
8. **Regresi area terdampak:** modul dari `git diff --name-only <base>...HEAD` → spec suite bertag `@area-<modul>` (`--grep @area-<modul>`); tidak ada → tulis "tidak ada spec regresi untuk area ini". Flaky → ulang sekali, tetap gagal = Gagal.
9. Spec TC yang Lulus dan stabil diusulkan untuk suite (`@area-<modul>`; `@smoke-live` hanya bila baca saja) — Coder yang menyalinnya ke repo atas tugas SPV.
10. Matikan server, hapus `storageState`, lepas kunci port dan akun.

## Keluaran
`${TMPDIR:-/tmp}/qa/<KODE>/report.md` + `*.png` sesuai Laporan uji; ringkasan Lulus/Gagal/Tertahan ke SPV.

## Tidak boleh
Tiket, platform dokumentasi, push, deploy; akun tanpa kunci; menulis data di production; isi kredensial di laporan.
