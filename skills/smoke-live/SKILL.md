---
name: smoke-live
description: Skill internal workflow Frontend. Uji baca-saja di production - hanya spec bertag @smoke-live, tanpa menulis data, tanpa akun nyata - setelah deploy production. Dipakai /branch-manager (QA).
argument-hint: "<vX.Y.Z> <URL production>"
---
Smoke live `$ARGUMENTS`. Baca: `browser.md`, `credentials.md` (akun `QA_LIVE_*`), `rules.md` (Data di staging/production).

## Langkah
1. Spec bertag `@smoke-live` dari suite (memory project). Tidak ada → hasil **belum ada smoke live** (risiko).
2. `npx playwright test <folder suite> --grep @smoke-live --trace off` dengan `baseURL` = URL production, ukuran desktop + ponsel. Login hanya dengan akun `QA_LIVE_*` bila spec membutuhkannya; tidak ada akun itu → spec yang butuh login **Tertahan**.
3. Cek tambahan baca-saja dengan `page-shot.mjs`: halaman utama + halaman yang diubah rilis ini, HTTP 200, tanpa console error baru.
4. Gagal → ulang sekali; tetap gagal = **Gagal** (screenshot bertanda).

## Keluaran
`${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/smoke-live.md` + `*.png`: tabel spec → hasil, URL + hash yang tampil.

## Tidak boleh
Submit form, membuat/mengubah/menghapus data, login akun nyata, fuzzing.
