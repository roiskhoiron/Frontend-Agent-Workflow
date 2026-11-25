---
name: split-questions
description: Skill internal workflow Frontend. Memecah permintaan atau keluhan yang belum jadi tiket menjadi gejala, halaman/route, browser/ukuran layar, versi/ref yang diperiksa, dan daftar pertanyaan yang bisa ditelusuri. Dipakai /audit-issue.
argument-hint: "\"<teks permintaan>\""
---
Pecah permintaan `$ARGUMENTS` (hanya-baca). Baca: `rules.md` (Periksa dulu, lalu tanya).

## Langkah
1. Ambil: gejala (apa yang terlihat vs yang diharapkan), halaman/route/komponen, browser + ukuran layar + perangkat, env (staging/production), waktu kejadian, akun/peran pengguna (tanpa kredensial).
2. **Versi/ref:** yang disebut; tidak ada → `git fetch --tags upstream`, tag `vX.Y.Z` terbaru (atau `upstream/<primary>`). Kode dibaca di ref itu tanpa checkout. URL production/staging dari memory project.
3. Susun pertanyaan yang bisa dijawab dengan bukti (kode, git, log, reproduksi, lampiran), bernomor. Kabur → periksa dulu, lalu tanya dengan satu saran.
4. Tandai pertanyaan yang butuh reproduksi browser dan yang butuh perbandingan lampiran.

## Keluaran
Blok: gejala, halaman, browser/ukuran, env + URL, ref versi, daftar pertanyaan bernomor (+ tanda reproduksi/lampiran).

## Tidak boleh
Menulis ke repo/tiket; menyimpulkan sebelum ada bukti.
