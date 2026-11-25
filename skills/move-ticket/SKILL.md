---
name: move-ticket
description: Skill internal workflow Frontend. Menggeser tiket ke status yang diizinkan (Todo, In Progress, Ready To Review) dengan id dari jira-transitions.json; tidak pernah Done. Dipakai /develop-tiket dan /rilis-tiket.
argument-hint: "KODE <Todo|In Progress|Ready To Review>"
---
Geser tiket `$ARGUMENTS`. Baca: `rules.md` (Setup transisi Jira).

## Langkah
1. Cari id status tujuan di `${AGENT_WORKFLOW_STATE:-$HOME/.agent-workflow}/jira-transitions.json` → `<PREFIX>.names`.
2. `transitionJiraIssue` dengan id itu.
3. Ditolak guard → jalankan "Setup transisi Jira" lalu ulangi sekali; tetap ditolak → lapor pesan guard.
4. Status tujuan Done atau tidak ada di daftar → berhenti dan lapor (Done hanya manusia).

## Keluaran
Status tiket sekarang.

## Tidak boleh
Done; menambah id ke daftar tanpa pilihan user.
