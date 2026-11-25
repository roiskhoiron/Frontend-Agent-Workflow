# Pasang di komputer lain

1. Prasyarat: Claude Code, Orca (disarankan), `git`, `jq`, `python3` + Pillow (`pip install pillow`), Node.js + Playwright (`npm i -g playwright && npx playwright install chromium`), `gh` atau `glab` (login), connector Atlassian di Claude.
2. Clone repo ini, lalu `./install.sh`. Yang dilakukan:
   - symlink `skills/*` ke `~/.claude/skills/` (`skills/_shared` → `_frontend-workflow-shared`) dan `agents/*.md` ke `~/.claude/agents/`;
   - hook guard `hooks/guard-frontend.sh` di `~/.claude/settings.json` (cadangan pertama: `settings.json.bak-frontend-workflow`);
   - jadwal pembersihan (macOS launchd; Linux: cetak baris crontab);
   - blok `# Frontend agent workflow` di `~/.claude/CLAUDE.md` (sekali).
   Aman dijalankan ulang.
3. **Bentrok dengan kit Mobile:** nama perintah dan agen sama (`/validate-tiket`, `spv.md`, ...). Bila sudah terpasang dari kit lain, `install.sh` menolak dan menyebut daftar bentroknya. `./install.sh --force` mengganti symlink kit lain (file/folder asli tidak pernah dihapus). Guard kedua kit boleh terpasang bersamaan. Satu mesin = satu kit aktif untuk perintah yang sama.
4. Sekali per project (agen menanyakannya saat pertama kali dipakai, lalu menyimpannya di memory project): platform tiket + transisi Jira, platform dokumentasi, branch `<primary>`/`<protected>`, framework + perintah, server API per env, hosting + cara deploy, matriks browser, suite regresi.
5. Per project: salin `templates/env.agent.local` ke root project sebagai `.env.agent.local`, **tambahkan ke `.gitignore` dulu**, lalu isi akun uji.
6. Opsional: daftar folder project di `~/.agent-workflow/build-roots.txt` (satu per baris) untuk pembersihan otomatis.
7. Mode tim butuh `claude --teammate-mode auto` (atau `/config` → Teammate mode → auto).
8. Cek: `bash tests/run.sh` → `ALL PASS`.

---
[← kembali ke README](../README.md)
