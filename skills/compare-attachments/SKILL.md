---
name: compare-attachments
description: Skill internal workflow Frontend. Membaca lampiran permintaan (mockup, gambar, PDF, link Figma/web) lalu membandingkannya dengan kode di ref dan halaman nyata, dalam tabel Lampiran | Kode | Halaman | Beda?. Dipakai /audit-issue (Analis).
argument-hint: "<slug> <ref> <lampiran...>"
---
Bandingkan lampiran `$ARGUMENTS` (hanya-baca). Baca: `rules.md`, `report-format.md`.

## Langkah
1. Buka semua lampiran: path lokal (gambar, PDF, mockup) dan link (Figma, Drive, web) bila alatnya tersedia. Gagal → nama + alasan, jangan dilewati diam-diam.
2. Daftar yang diminta lampiran (perilaku, teks, tata letak per ukuran layar, aturan) dengan rujukan persis (halaman, frame, bagian).
3. Bandingkan dengan kode di ref (`git show <ref>:<path>`) dan screenshot halaman dari Auditor bila ada.
4. Tabel `Lampiran | Kode | Halaman | Beda?`, tiap beda dengan keyakinan **pasti** / **kuat** / **dugaan**.

## Keluaran
`${TMPDIR:-/tmp}/audit/<slug>/<nama agen atau compare-attachments>.md`.

## Tidak boleh
Mengubah repo/tiket/PR/dokumen; memakai browser untuk reproduksi (itu Auditor); menyalin kredensial/data pribadi dari lampiran.
