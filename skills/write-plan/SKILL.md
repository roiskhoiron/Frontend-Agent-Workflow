---
name: write-plan
description: Skill internal workflow Frontend. Menyusun dokumen rencana kerja + test case tiket (tugas bernomor dengan batas file, TC per AC x server x ukuran layar, aksesibilitas, risiko untuk Reviewer) sebagai Markdown lokal untuk diterbitkan. Dipakai /develop-tiket (Planner di mode tim, SPV di mode solo).
argument-hint: "KODE... [--revisi|--eskalasi]"
---
Susun rencana untuk `$ARGUMENTS`. Masukan: Acuan tiket, Yang ditolak (bila ada), worktree + branch + base hash, Matriks env, framework, matriks browser, batasan batch. Baca: `rules.md`, `browser.md`, `report-format.md` (Rencana).

## Langkah
1. Baca laporan validasi, dokumen di Acuan, dan kode terkait di worktree tiket (hanya-baca). Informasi kurang → satu daftar pertanyaan ke SPV, satu putaran; belum terjawab → "Pertanyaan terbuka", status **Butuh jawaban**.
2. Tulis `${TMPDIR:-/tmp}/plan/<KODE>/rencana.md` (`--batch`: satu file untuk semua tiket) dengan bagian di `report-format.md` → Rencana:
   - **Tugas desain:** tugas pertama tiket UI = sinkron token dari repo desain (ref tercatat); layar ditulis ulang di framework proyek dari prototipe + halaman handover, **bukan** menyalin kode prototipe.
   - **Tugas bernomor:** komponen/route/hook/store yang diubah, urutan, ketergantungan, pembagian per Coder dengan batas file; perubahan dependensi `package.json` disebut eksplisit.
   - **Test case:** ID TC, AC, server (endpoint **Belum ada** di server itu → TC Tertahan di server itu, atau memakai mock dari kontrak bila disetujui), ukuran layar (semua dari matriks untuk TC UI), alat (Playwright, axe, Schemathesis, Pact, unit/komponen), alamat state prototipe acuan (satu TC UI per state yang relevan, `design-input.md`).
   - **Yang ditolak:** tiap poin → nomor tugas dan/atau ID TC (poin tanpa tugas/TC tidak boleh).
   - **Risiko untuk Reviewer:** XSS/sanitasi, token/rahasia di bundle, otorisasi sisi klien, ukuran bundle, render berulang, layout shift, aturan bisnis yang mudah meleset.
3. `--revisi`/`--eskalasi`: perbarui file yang sama, tambah bagian "Perubahan" (apa dan kenapa).

## Keluaran
Path `rencana.md`, ringkasan ≤ 10 baris, status **Siap** / **Butuh jawaban** / **Tidak bisa** + pertanyaan.

## Tidak boleh
Menulis kode produk, mengubah repo, menulis ke tiket/platform dokumentasi (penerbitan oleh flow), merencanakan hal yang menabrak guard atau daftar "berhenti dan tanya".
