---
name: setup-board
description: Skill internal workflow Frontend. Memastikan platform tiket (default Jira) tercatat di memory project, Atlassian MCP terjangkau, dan daftar transisi project ada. Dijalankan di awal /validate-tiket, /develop-tiket, /rilis-tiket, /branch-manager.
argument-hint: KODE
---
Pastikan platform tiket siap dipakai untuk KODE di `$ARGUMENTS`. Aturan: `~/.claude/skills/_frontend-workflow-shared/rules.md` (Lokasi, Setup transisi Jira).

## Langkah
1. Baca memory project: **Platform tiket** + prefix KODE. Belum ada → saran "Jira, prefix `<prefix dari KODE>`", tanya user sekali, simpan sebagai memory project tipe `reference`.
2. Platform bukan Jira → berhenti dan tanya: v1 kit ini hanya punya adapter Jira.
3. Atlassian MCP terjangkau: `atlassianUserInfo` (nama tool berbeda per mesin, mis. `mcp__claude_ai_Atlassian__atlassianUserInfo` atau `mcp__Atlassian__atlassianUserInfo`). Gagal → berhenti, minta user menyambungkan connector Atlassian.
4. `${AGENT_WORKFLOW_STATE:-$HOME/.agent-workflow}/jira-transitions.json` punya entri prefix itu dengan id yang dibutuhkan flow (Todo, In Progress, Ready To Review). Belum → jalankan "Setup transisi Jira" di `rules.md` (user memilih id; Done tidak pernah).

## Keluaran
Satu baris: `board=jira prefix=<PREFIX> transisi=<nama status yang tersedia>`.

## Tidak boleh
Menulis id Done ke daftar transisi; menyimpan token/kredensial di memory.
