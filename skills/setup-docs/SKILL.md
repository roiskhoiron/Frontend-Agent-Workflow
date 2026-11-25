---
name: setup-docs
description: Skill internal workflow Frontend. Memastikan platform dokumentasi (default Markdown di folder docs/ lewat worktree <repo>-docs) tercatat di memory project dan siap ditulisi. Dijalankan di awal /validate-tiket, /develop-tiket, /branch-manager, /audit-issue.
argument-hint: "[repo]"
---
Siapkan tempat laporan. Aturan: `~/.claude/skills/_frontend-workflow-shared/report-format.md` (Platform dokumentasi), `rules.md`.

## Langkah
1. Baca memory project: **Platform dokumentasi**. Belum ada → saran `repo-markdown` (folder `docs/` di branch `agent-docs` milik `origin`), tanya user sekali, simpan sebagai memory project tipe `reference` (platform, nama branch, folder, atau id ruang/space untuk platform lain).
2. `repo-markdown`:
   - Worktree dokumen `<repo>-docs` sejajar checkout ada? (`git worktree list`). Belum → `git fetch origin`; branch `origin/agent-docs` ada → `git -C <checkout> worktree add ../<repo>-docs agent-docs`, belum → `git -C <checkout> worktree add ../<repo>-docs -b agent-docs upstream/<protected>` lalu `git -C ../<repo>-docs push -u origin agent-docs`.
   - `git -C ../<repo>-docs status --porcelain` kosong; tidak kosong → berhenti dan tanya (ada perubahan yang belum di-commit).
   - Catat pola URL forge: `git remote get-url origin` → `https://<host>/<owner>/<repo>/blob/agent-docs/`.
3. `claude-docs`: connector Claude Docs tersedia di sesi (cari tool `batch`/`read`). Tidak ada → tanya user: sambungkan, atau pakai `repo-markdown`.
4. Platform lain: cek alat/connector-nya tersedia; tidak ada → tanya.

## Keluaran
`docs=<platform> lokasi=<path worktree / space> url=<pola URL>`.

## Tidak boleh
Menghapus atau me-reset worktree dokumen; menulis ke worktree primary.
