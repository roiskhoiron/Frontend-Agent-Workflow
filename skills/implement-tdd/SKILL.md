---
name: implement-tdd
description: Skill internal workflow Frontend. Prosedur Coder - pastikan desain dan kontrak dulu (daftar cek silang ke SPV), TDD (tes gagal, kode minimum, rapikan), micro-interaction sederhana yang menghormati reduced motion, commit menyebut KODE, push rutin branch tiket. Dipakai /develop-tiket langkah 3.
argument-hint: "KODE <worktree> [batas file]"
---
Implementasi `$ARGUMENTS` di worktree tiket. Baca: `rules.md`, `browser.md`, `credentials.md`.

## Langkah
1. Pastikan di worktree + branch tiket yang ditugaskan; ubah hanya file dalam batas tugas. Jangan checkout branch lain, jangan buat/hapus worktree.
2. **Cek silang sebelum kode** (satu pesan ke SPV, tunggu jawaban): kontrak API yang dipakai (path, method, field, kode galat, status Matriks env per server) dan detail desain yang di-slice per ukuran layar (layout, spacing, token warna/tipografi dari design system, teks, state kosong/loading/error/disabled, hover/focus, mode gelap). Tidak ada mockup → tanya; SPV bilang memang tidak ada → ikuti komponen sejenis di project, sebut di laporan.
3. **TDD:** unit/komponen dengan runner project (Vitest/Jest + Testing Library; query berbasis peran/label, bukan class) → tes gagal → kode minimum → lulus → rapikan. Logika bisnis di fungsi/hook yang bisa diuji tanpa DOM.
4. **UI:** pakai komponen dan token design system yang ada; HTML semantik, label form, `alt`, fokus terlihat, urutan Tab logis. Responsif mobile-first sesuai matriks.
5. **Micro-interaction sederhana**, tanpa diminta: feedback hover/active/focus, state loading/disabled di tombol, transisi state (fade/slide pendek) 150–300 ms dengan CSS `transition` atau pustaka animasi yang sudah ada di project; bungkus dengan `@media (prefers-reduced-motion: reduce)`; tidak menghalangi input, tidak menggeser layout (pakai `transform`/`opacity`). Daftar yang ditambahkan ditulis di laporan.
6. Endpoint belum ada di dev → kerja terhadap mock kontrak (port dari SPV).
7. Commit kecil, pesan menyebut KODE (`fix: PROJ-1234 validasi nomor`). **Push rutin** `git push origin <branch tiket>` tiap commit yang tesnya lulus. Hanya branch tiketmu, hanya `origin`, tanpa force.
8. Sebelum lapor: lint, typecheck, seluruh tes project, dan build produksi (`build`) lulus di worktree tiket.

## Keluaran (ke SPV)
Ringkasan perubahan, commit, hasil lint/typecheck/test/build, desain acuan yang dipakai, micro-interaction yang ditambahkan, perubahan dependensi (bila ada).

## Tidak boleh
Tiket/platform dokumentasi; push selain branch tiketmu; deploy; rahasia di kode klien atau file ter-track; mengubah lockfile tanpa disebut di rencana.
