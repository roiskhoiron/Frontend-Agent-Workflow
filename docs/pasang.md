# Pasang

Kit ini bisa dipakai di beberapa **agen coding**, untuk **semua project** (global) atau **satu project** saja.

## 1. Prasyarat
`git`, `jq`, `python3` + Pillow (`pip install pillow`), Node.js + Playwright (`npm i -g playwright && npx playwright install chromium`), `gh` atau `glab` yang sudah login, dan minimal satu agen coding dari tabel di bawah. Orca disarankan untuk kerja paralel. Alat platform tiket menyesuaikan pilihan project: GitHub/GitLab cukup `gh`/`glab`; Jira butuh connector Atlassian; Linear butuh connector Linear.

## 2. Jalankan installer
```bash
git clone https://github.com/roiskhoiron/Frontend-Agent-Workflow.git
cd Frontend-Agent-Workflow
./install.sh
```
Installer bertanya dua hal:
1. **Agen coding mana?** Boleh lebih dari satu (mis. `1,3`).
2. **Global atau project?** Global = semua project di komputer ini. Project = satu folder project (ditanya path-nya).

Tanpa pertanyaan (untuk skrip/CI):
```bash
./install.sh --agent claude --scope global
./install.sh --agent codex,gemini --scope project --project ~/kode/toko-web
./install.sh --agent all --scope global --yes
```
Aman dijalankan ulang. Cek kit: `bash tests/run.sh` → `ALL PASS`.

## 3. Yang dipasang per agen

| Agen (`--agent`) | Skill | Pagar (guard) | File instruksi (global / project) |
|---|---|---|---|
| `claude` (Claude Code) | `.claude/skills/` + 15 peran di `.claude/agents/` | hook `PreToolUse` di `~/.claude/settings.json` / `.claude/settings.local.json` | `~/.claude/CLAUDE.md` / `CLAUDE.md` |
| `codex` (OpenAI Codex) | `.agents/skills/` | hook `PreToolUse` (Bash) di `~/.codex/hooks.json` / `.codex/hooks.json` | `~/.codex/AGENTS.md` / `AGENTS.md` |
| `gemini` (Gemini CLI) | `.agents/skills/` | hook `BeforeTool` (shell + tulis file) di `~/.gemini/settings.json` / `.gemini/settings.json` | `~/.gemini/GEMINI.md` / `GEMINI.md` |
| `copilot` (GitHub Copilot CLI/VS Code) | `.agents/skills/` | hook `preToolUse` di `~/.copilot/hooks/frontend-workflow.json` / `.github/hooks/frontend-workflow.json` | — / `AGENTS.md` |
| `cursor` | `.agents/skills/` | hook `beforeShellExecution` di `~/.cursor/hooks.json` / `.cursor/hooks.json` (hanya perintah shell) | — / `AGENTS.md` |
| `opencode` | `.agents/skills/` | belum ada (aturan saja) | `~/.config/opencode/AGENTS.md` / `AGENTS.md` |
| `generic` (agen lain yang membaca `AGENTS.md` dan `.agents/skills`) | `.agents/skills/` | belum ada (aturan saja) | — / `AGENTS.md` |

`.agents/skills/` = `~/.agents/skills/` (global) atau `<project>/.agents/skills/` (project). Folder ini dibaca bersama oleh Codex, Gemini CLI, Copilot, Cursor, dan OpenCode.

Selalu dipasang, apa pun agennya:
- `~/.agent-workflow/frontend-kit` → folder repo ini. Semua skill membaca aturan dan skrip lewat path ini, jadi sama di semua agen.
- Memory project: `~/.agent-workflow/projects/<owner>__<repo>.md` (diisi agen saat bertanya pertama kali).
- Pembersihan berkala (macOS launchd; Linux: baris crontab dicetak installer).

Pagar untuk agen selain Claude lewat `hooks/guard-adapter.sh <agen>`: payload hook agen itu diterjemahkan ke format guard yang sama, lalu penolakan dijawab dalam format agen itu.

## 4. Scope project: apa yang masuk git
- Symlink skill dan file hook yang baru dibuat berisi path lokal komputermu, jadi installer menambahkannya ke `.git/info/exclude` (tidak ikut commit, tidak mengubah `.gitignore`).
- Blok `# Frontend agent workflow` di `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` **sengaja tidak** di-exclude: commit bila timmu ingin memakainya.
- Codex: hook project baru jalan setelah project di-*trust* di Codex. Gemini CLI juga menandai hook project yang berubah sebagai belum dipercaya.

## 5. Bentrok dengan kit lain
Nama perintah dan agen sama dengan kit Mobile (`/validate-tiket`, `spv.md`, ...). Bila sudah terpasang dari kit lain, installer menolak dan menyebut daftar bentroknya. `--force` mengganti symlink kit lain (file/folder asli tidak pernah dihapus). Guard kedua kit boleh terpasang bersamaan.

## 6. Setelah dipasang (sekali per project)
1. Salin `templates/env.agent.local` ke root project sebagai `.env.agent.local`, **tambahkan ke `.gitignore` dulu**, lalu isi akun uji.
2. Jalankan perintah pertama. Agen bertanya platform tiket (tidak ada default), lalu branch, hosting, server API, ukuran layar, dan tempat laporan; jawabannya disimpan di memory project.
3. Opsional: daftar folder project di `~/.agent-workflow/build-roots.txt` untuk pembersihan otomatis.
4. Mode tim (`--tim`): Claude Code butuh `claude --teammate-mode auto`. Agen lain memakai subagent bawaannya bila ada; kalau tidak, perintah berjalan sebagai solo.

## Batasan yang perlu diketahui
- Pagar paling lengkap di Claude Code. Di Codex, Gemini CLI, dan Copilot pagar mencegat perintah shell dan tulis file; di Cursor hanya shell; OpenCode dan `generic` belum punya pagar otomatis.
- Format hook Cursor belum diverifikasi ke dokumentasi resminya; uji dulu dengan perintah yang pasti diblokir (mis. `git push upstream main`).
- Model per peran (Opus/Sonnet/Haiku/Fable) hanya berlaku di Claude Code; agen lain memakai model yang tersedia di sana.

---
[← kembali ke README](../README.md)
