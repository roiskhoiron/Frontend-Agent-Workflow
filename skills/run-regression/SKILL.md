---
name: run-regression
description: Skill internal workflow Frontend. Menjalankan suite regresi Playwright penuh (atau per tag area) terhadap deploy staging dari sha rilis, di ukuran layar dari matriks, dengan akun uji dan data berawalan versi. Dipakai /branch-manager (QA).
argument-hint: "<vX.Y.Z> <URL staging> [--grep @area-<modul>]"
---
Regresi `$ARGUMENTS`. Baca: `browser.md`, `credentials.md`, `rules.md` (Isi memory project: Suite regresi).

## Langkah
1. **Suite** dari memory project (folder spec + aturan tag). Belum ada → tanya lewat SPV, simpan. Suite kosong → hasil **belum ada suite regresi** (risiko, bukan lulus).
2. Jalankan di worktree rilis (ref `<sha-rilis>`): `npx playwright test <folder suite> --trace off` dengan `baseURL` = URL staging (variabel env yang dipakai config project), proyek/ukuran layar dari matriks, akun uji terkunci, data uji berawalan versi.
3. Flaky → ulang spec itu sekali; tetap gagal = **Gagal**. Screenshot langkah yang gagal, bertanda.
4. Cocokkan spec gagal dengan tiket yang menyentuh modulnya (tabel tracing) untuk rekomendasi.
5. Lepas kunci akun.

## Keluaran
`${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/regresi.md` + `*.png`: tabel `spec | ukuran | Lulus/Gagal/Tertahan | tiket terkait`, URL + hash + env API.

## Tidak boleh
Menjalankan suite penuh ke production; menulis data tanpa awalan versi; menganggap suite kosong sebagai lulus.
