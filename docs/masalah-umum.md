# Masalah umum

| Gejala | Artinya / yang dilakukan |
| --- | --- |
| "DIBLOKIR oleh guard: ..." | Perintah melanggar pagar. Baca pesannya; biasanya menyebut cara yang benar |
| `install.sh`: "Tidak dipasang: nama skill/agen ini sudah dipakai kit lain" | Kit Mobile (atau lainnya) sudah memasang perintah/agen dengan nama sama. Pilih satu kit per mesin, atau `./install.sh --force` |
| "Teammate mode mati" (Claude Code) | Buka ulang dengan `claude --teammate-mode auto`, lalu ulangi perintah |
| Pagar tidak jalan di Codex / Gemini CLI | Hook scope project baru aktif setelah project di-*trust* di agen itu. Cek dengan perintah yang pasti ditolak: `git push upstream main` |
| Skill tidak muncul di agen non-Claude | Pastikan agen membaca `~/.agents/skills` atau `<project>/.agents/skills`; tanpa fitur skill, minta agen membaca `~/.agent-workflow/frontend-kit/skills/<perintah>/SKILL.md` |
| "Jalankan dari workspace domain" | `/develop-tiket` dijalankan dari root project. Buka workspace domain di Orca |
| Agen bertanya "tiket dikelola di mana?" | Project belum punya catatan platform tiket. Jawab Jira / GitHub / GitLab / Linear; belum punya → terima saran agen (GitHub Projects atau GitLab Issue Board) |
| "belum punya daftar status" | Agen menunjukkan status di papanmu; pilih untuk Todo, In Progress, Ready To Review (Done tidak pernah) |
| "issue close dilarang" | Menutup issue = Done, hanya manusia. Agen berhenti di Ready To Review |
| `port-pick.sh` exit 1 | Semua port 4100–4199 terpakai/terkunci. Matikan dev server lama, atau kunci yang pemiliknya sudah mati akan diambil ulang otomatis |
| `page-shot.mjs` exit 3 | Playwright tidak ditemukan atau halaman gagal dibuka. Pasang Playwright global, cek server/URL |
| `page-shot.mjs` exit 1 | Selector tidak ditemukan; dicatat di laporan, tidak ditebak |
| Link laporan tidak bisa dibuka | `repo-markdown`: branch `agent-docs` belum di-push atau fork privat; cek `git -C ../<repo>-docs log origin/agent-docs` |
| Deploy pratinjau tidak muncul | Hosting otomatis per PR belum aktif, atau CLI hosting belum login. Agen bertanya; token tidak pernah ditulis ke file |
| `compare-shot.py` exit 1 | Halaman beda dari prototipe di atas ambang. QA melihat gambar banding; beda kecil font/anti-aliasing diabaikan, beda layout/warna/teks = TC gagal |
| Agen bertanya repo desain | Project belum mencatat repo prototipe workflow UI/UX. Beri URL repo `<proyek>-design` dan alamat GitHub Pages-nya; belum memakai workflow UI/UX → jawab "belum", agen memakai gambar di tiket |
| TC **Tertahan** | Tidak bisa diuji (endpoint belum ada, state prototipe tidak bisa dicapai, akun tidak ada); alasannya tertulis di laporan |

---
[← kembali ke README](../README.md)
