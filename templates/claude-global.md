# Frontend agent workflow
- Perintah: `/validate-tiket`, `/develop-tiket`, `/rilis-tiket`, `/branch-manager`, `/audit-issue` (kit Frontend web). Aturan bersama: `~/.claude/skills/_frontend-workflow-shared/rules.md`.
- Skill flow menjalankan skill internal berurutan (mis. `/read-ticket`, `/test-browser`, `/deploy-preview`); skill internal tidak saling memanggil.
- Workspace Orca: kerja kode di workspace domain yang dibuka user (id `$ORCA_WORKTREE_ID`); tiap tiket punya worktree `<repo>-<nomor>` sejajar checkout domain dan port dev server sendiri (`port-pick.sh`). Multi-agent = teammate (panel split), bukan tab, workspace, atau project baru.
- Keputusan per project disimpan di memory project; agen tidak menulis CLAUDE.md project, tetapi memberi blok `## Catatan agen` untuk di-commit user.
