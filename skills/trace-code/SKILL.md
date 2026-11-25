---
name: trace-code
description: Skill internal workflow Frontend. Menelusuri kode di ref versi tanpa checkout, riwayat git (log, blame), dan log/monitoring yang tersedia (Sentry, log hosting, console) untuk menjawab pertanyaan audit dengan bukti. Dipakai /audit-issue (Auditor).
argument-hint: "<slug> <ref> <nomor pertanyaan...>"
---
Telusuri `$ARGUMENTS` (hanya-baca). Baca: `rules.md`, `report-format.md` (Laporan audit).

## Langkah
1. Kode tanpa checkout: `git show <ref>:<path>`, `git grep <pola> <ref>`, `git log <ref> -- <path>`, `git blame <ref> -- <path>`. Mulai dari route/halaman → komponen → hook/store → API client. Graph `graphify-out/` bila ada.
2. Konfigurasi build/hosting di ref (env yang dipakai, rewrite/redirect, header, CSP) bila relevan.
3. Log/monitoring (Sentry, log hosting, analytics) hanya bila alatnya tersedia dan sudah login di sesi; tidak → "tidak bisa diperiksa" + alasan.
4. Tiap klaim dengan bukti (file:baris di ref, commit, potongan log) dan keyakinan **pasti** / **kuat** / **dugaan**.

## Keluaran
`${TMPDIR:-/tmp}/audit/<slug>/<nama agen atau trace-code>.md`: jawaban per pertanyaan + bukti + keyakinan.

## Tidak boleh
Checkout, commit, branch, stash, edit file repo (mode audit memblokirnya); tulis ke tiket/PR.
