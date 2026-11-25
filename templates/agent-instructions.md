# Frontend agent workflow
- Kit agen untuk tiket frontend web. Perintah: `/validate-tiket`, `/develop-tiket`, `/rilis-tiket`, `/branch-manager`, `/audit-issue`. Aturan bersama: `~/.agent-workflow/frontend-kit/skills/_shared/rules.md` (baca dulu sebelum menjalankan perintah itu).
- Perintah dijalankan sebagai skill. Agen coding tanpa fitur skill: baca `~/.agent-workflow/frontend-kit/skills/<perintah>/SKILL.md` lalu ikuti langkahnya. Skill flow menjalankan skill internal berurutan (mis. `/read-ticket`, `/test-browser`, `/deploy-preview`); skill internal tidak saling memanggil.
- Tidak ada platform tiket default: bila memory project (`~/.agent-workflow/projects/<owner>__<repo>.md`) belum mencatatnya, tanya user dulu.
- Kerja kode di worktree tiket `<repo>-<nomor>` dengan port dev server sendiri (`port-pick.sh`). Agen coding tanpa subagent/teammate: `--tim` jalan sebagai solo.
- Tidak pernah: push ke selain `origin`, deploy production tanpa izin, menutup issue / memindah tiket ke Done, menulis kredensial. Keputusan per project tidak ditulis agen ke file instruksi project; agen memberi blok `## Catatan agen` untuk di-commit user.
