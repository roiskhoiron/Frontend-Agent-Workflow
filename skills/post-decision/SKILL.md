---
name: post-decision
description: Skill internal workflow Frontend. Menulis komentar keputusan validasi di tiket (baris pertama link laporan, bahasa awam) lalu menggeser tiket ke In Progress bila Layak / Layak dengan catatan. Dipakai /validate-tiket.
argument-hint: "KODE <Layak|Layak dengan catatan|Tidak layak> <link laporan>"
---
Umumkan keputusan validasi `$ARGUMENTS`. Baca: `report-format.md` (Komentar tiket), `rules.md` (Setup transisi Jira).

## Langkah
1. Tulis komentar sesuai gaya di `report-format.md`: sapaan ke reporter, baris pertama memuat link laporan, keputusan dalam bahasa awam, alasan singkat, yang perlu dilengkapi (Tidak layak / catatan), tiket terkait yang disarankan di-link. Kirim dengan `addCommentToJiraIssue`.
2. **Layak** / **Layak dengan catatan** → `transitionJiraIssue` ke In Progress, id dari `jira-transitions.json`. **Tidak layak** → tetap Todo.
3. Transisi ditolak guard → jalankan "Setup transisi Jira" (`rules.md`), jangan memutar.

## Keluaran
Link komentar + status tiket sekarang.

## Tidak boleh
Komentar tanpa link laporan; Done; kredensial atau istilah teknis tanpa penjelasan.
