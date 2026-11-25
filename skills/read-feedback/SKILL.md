---
name: read-feedback
description: Skill internal workflow Frontend. Membaca feedback QA/manusia terakhir di tiket dan PR/MR (setelah komentar agen terakhir) lalu menggolongkannya - ditolak, minta deploy, positif, Done, atau tidak ada feedback. Dipakai /rilis-tiket.
argument-hint: KODE
---
Baca feedback terakhir `$ARGUMENTS` (baca saja). Baca: `rules.md`.

## Langkah
1. `getJiraIssue` + komentar: status (Ready To Review / Done; lainnya → golongan **di luar cakupan**).
2. PR/MR tiket (`gh pr list --repo <upstream> --state all --search <KODE>` / `glab mr list --all --search <KODE>`) + komentar review.
3. **Feedback terakhir** = komentar manusia terbaru (tiket + PR/MR) setelah komentar agen terakhir.
4. Golongkan:
   | Keadaan | Golongan |
   |---|---|
   | Status Done + punya PR/MR | **Done** |
   | Ditolak QA/reviewer | **Ditolak** (ringkas: apa, dari siapa, di mana) |
   | Positif, belum Done, minta deploy staging/production | **Minta deploy** (env yang diminta) |
   | Positif tanpa permintaan | **Positif** |
   | Tidak ada feedback | **Tidak ada** |
   Beberapa sekaligus → urutan **Done > Ditolak > Minta deploy**. Bertentangan → **Perlu keputusan** + kutipan kedua pihak.

## Keluaran
`KODE | status | golongan | ringkasan + sumber | PR/MR`.

## Tidak boleh
Menulis/menggeser tiket; menebak bila feedback bertentangan.
