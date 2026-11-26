---
name: gate-validation
description: Skill internal workflow Frontend. Gerbang validasi sebelum pengerjaan - membaca laporan validasi terbaru, membandingkan dokumen terbaru dengan ref saat validasi, dan menyusun Acuan tiket (+ daftar Yang ditolak untuk tiket revisi). Dipakai /develop-tiket langkah 1.
argument-hint: KODE
---
Gerbang validasi untuk `$ARGUMENTS`. Masukan: ringkasan tiket (AC, jejak, penolakan) dan tabel ref dokumen terbaru dari langkah sebelumnya. Baca: `rules.md`, `design-input.md`, `report-format.md`.

## Langkah
1. Cari komentar laporan validasi terbaru di tiket (baris pertama = link laporan) dan **baca laporannya**.
   | Kondisi | Hasil |
   |---|---|
   | Belum pernah divalidasi | **Tanya**: jalankan `/validate-tiket` dulu (saran), atau lanjut dengan cek singkat SPV yang dicatat di rencana |
   | **Tidak layak** | **Berhenti** dan tanya |
   | **Layak dengan catatan** | Lanjut; tiap catatan jadi tugas atau TC |
   | **Layak** | Lanjut |
2. **Dokumen terbaru vs saat validasi:** bandingkan ref business discovery, prototipe/repo desain, kontrak API, blueprint yang tercatat di laporan dengan ref terbaru. Berubah dan menyentuh AC/desain/kontrak → sebut perbedaannya, **tanya** sebelum lanjut; berubah kecil → catatan rencana.
3. **Tiket dengan jejak:** susun daftar **Yang ditolak** dari komentar penolakan (sumber + kutipan singkat). Bertentangan dengan laporan validasi ulang → tanya. Penolakan tidak diketahui → tanya user apa yang ditolak.
4. Susun **Acuan tiket**: link/path + ref tiap dokumen (business discovery, **masukan desain** sesuai `design-input.md`: alamat tiap state prototipe + halaman handover + ref repo desain untuk token, kontrak API, blueprint), link laporan validasi, keputusan validasi. Dokumen tidak ada di sumber → "tidak ada"; tiket UI tanpa prototipe → tanya (project tanpa workflow UI/UX: gambar/mockup di tiket).

## Keluaran
Status gerbang (**lanjut** / **tanya: ...** / **berhenti: ...**), Acuan tiket (tabel), Yang ditolak (bila ada).

## Tidak boleh
Lanjut melewati status **tanya**/**berhenti**; mengubah tiket.
