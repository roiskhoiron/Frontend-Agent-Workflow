---
name: post-summary
description: Skill internal workflow Frontend. Merangkum semua link hasil pengerjaan (laporan uji, rencana, deploy pratinjau, PR/MR, ringkasan Lulus/Tertahan per server) dalam satu komentar tiket berbahasa awam. Dipakai /develop-tiket dan /rilis-tiket (Release).
argument-hint: "KODE <link laporan> [link lain...]"
---
Komentar ringkasan untuk `$ARGUMENTS`. Baca: `report-format.md` (Komentar tiket).

## Langkah
1. Pastikan link laporan ada dan bisa dibuka; tidak ada → berhenti (jangan komentar tanpa link).
2. Susun komentar: sapaan ke reviewer/assignee, **baris pertama link laporan**, lalu apa yang dikerjakan dalam bahasa awam, hasil uji (laptop/tablet/HP; yang tertahan + alasan sederhana), link halaman pratinjau beserta server datanya (mis. "pakai data server uji"), link rencana dan PR/MR.
3. Kirim dengan operasi **Komentar** (`board.md`).

## Keluaran
Link komentar.

## Tidak boleh
Kredensial; istilah teknis tanpa arti; menggeser tiket (itu langkah terpisah).
