---
name: post-decision
description: Skill internal workflow Frontend. Menulis komentar keputusan validasi di tiket (platform apa pun dari memory project) (baris pertama link laporan, bahasa awam) lalu menggeser tiket ke In Progress bila Layak / Layak dengan catatan. Dipakai /validate-tiket.
argument-hint: "KODE <Layak|Layak dengan catatan|Tidak layak> <link laporan>"
---
Umumkan keputusan validasi `$ARGUMENTS`. Baca: `report-format.md` (Komentar tiket), `board.md` (operasi per platform, Setup status papan).

## Langkah
1. Tulis komentar sesuai gaya di `report-format.md`: sapaan ke reporter, baris pertama memuat link laporan, keputusan dalam bahasa awam, alasan singkat, yang perlu dilengkapi (Tidak layak / catatan), tiket terkait yang disarankan di-link. Kirim dengan operasi **Komentar** (`board.md`).
2. **Layak** / **Layak dengan catatan** → operasi **Geser status** ke In Progress, nilai dari `board-status.json`. **Tidak layak** → tetap Todo.
3. Transisi ditolak guard → jalankan "Setup status papan" (`board.md`), jangan memutar.

## Keluaran
Link komentar + status tiket sekarang.

## Tidak boleh
Komentar tanpa link laporan; Done; kredensial atau istilah teknis tanpa penjelasan.
