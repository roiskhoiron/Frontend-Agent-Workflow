---
name: move-ticket
description: Skill internal workflow Frontend. Menggeser tiket ke status yang diizinkan (Todo, In Progress, Ready To Review) dengan nilai dari board-status.json, di platform tiket mana pun (Jira, GitHub Projects, label GitHub/GitLab); tidak pernah Done. Dipakai /develop-tiket dan /rilis-tiket.
argument-hint: "KODE <Todo|In Progress|Ready To Review>"
---
Geser tiket `$ARGUMENTS`. Baca: `board.md` (operasi Geser status, Setup status papan).

## Langkah
1. Cari nilai status tujuan (id transisi / opsi project / label) di `${AGENT_WORKFLOW_STATE:-$HOME/.agent-workflow}/board-status.json` → `<PREFIX>.names` (Jira: juga `jira-transitions.json`).
2. Jalankan operasi **Geser status** platform itu (`board.md`). Label: tambah label baru dan lepas label status lama dalam satu perintah.
3. Ditolak guard → jalankan "Setup status papan" (`board.md`) lalu ulangi sekali; tetap ditolak → lapor pesan guard.
4. Status tujuan Done atau tidak ada di daftar → berhenti dan lapor (Done hanya manusia).

## Keluaran
Status tiket sekarang.

## Tidak boleh
Done; menutup issue; menambah nilai ke daftar tanpa pilihan user.
