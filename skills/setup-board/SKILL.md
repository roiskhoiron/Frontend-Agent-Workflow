---
name: setup-board
description: Skill internal workflow Frontend. Memastikan platform tiket project tercatat di memory project (default none - tanya user dulu; bila bingung sarankan GitHub Projects atau GitLab Issue Board), alatnya terjangkau, prefix KODE jelas, dan daftar status papan ada. Dijalankan di awal /validate-tiket, /develop-tiket, /rilis-tiket, /branch-manager.
argument-hint: "[KODE]"
---
Pastikan platform tiket siap dipakai (KODE di `$ARGUMENTS` bila ada). Aturan: `~/.claude/skills/_frontend-workflow-shared/board.md`, `rules.md`.

## Langkah
1. Baca memory project: **Platform tiket**. Tidak ada (= none) → **jangan menebak dan jangan membaca tiket dulu**:
   - kumpulkan fakta (remote upstream GitHub/GitLab, connector di sesi, pola KODE yang diketik user);
   - tanya user dengan pertanyaan di `board.md` → Pertanyaan pertama;
   - user bingung/belum punya → sarankan satu alternatif (GitHub Projects untuk repo GitHub, GitLab Issue Board untuk repo GitLab), beri langkah singkat membuatnya, tunggu sampai siap;
   - simpan jawaban (platform, lokasi, prefix KODE, nama status, alat) sebagai memory project tipe `reference`.
2. Platform tercatat → cek akses dengan operasi **Cek akses** (`board.md`). Gagal → berhenti, minta user menyambungkan connector atau login CLI.
3. **KODE:** normalkan argumen ke `<PREFIX>-<nomor>` (`board.md` → KODE tiket); tidak bisa → tanya.
4. **Daftar status:** `${AGENT_WORKFLOW_STATE:-$HOME/.agent-workflow}/board-status.json` punya entri prefix itu dengan status yang dibutuhkan flow (Todo, In Progress, Ready To Review). Untuk Jira, `jira-transitions.json` (kit Mobile) juga berlaku. Belum → "Setup status papan" di `board.md` (user memilih; Done tidak pernah).

## Keluaran
Satu baris: `board=<platform> lokasi=<...> prefix=<PREFIX> status=<nama yang tersedia>`.

## Tidak boleh
Menganggap platform tertentu sebagai default; membuat board/project sendiri; memasukkan Done ke daftar status; menyimpan token di memory.
