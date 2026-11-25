# Tim agen

Dua kelompok, sama dengan Mobile. **Management** memutuskan dan berbicara ke luar (tiket, dokumen, git remote, hosting). **Development** hanya kode dan browser.

| Agen | Nama | Model | Tugas utama | Dipakai di |
|---|---|---|---|---|
| SPV | Pak Darmo | Opus | Bagi tugas, port + akun uji, putuskan selesai | `/develop-tiket` |
| Planner | Pak Sastro | Fable | Rencana + test case, analisis eskalasi | `/develop-tiket --tim` |
| Validator | Kang Jajang | Opus | Validasi tiket; mode tim = SPV validasi | `/validate-tiket` |
| PdM | Bu Ratmi | Sonnet | Dokumen bisnis vs AC | `/validate-tiket --tim` |
| Product Designer | Neng Lilis | Sonnet (eskalasi Opus) | Mockup web vs halaman, bug UI | `/validate-tiket --tim` |
| Contract Runner | Kang Ohim | Sonnet | Schemathesis + Pact, Matriks env | validasi tim, `/develop-tiket` |
| HoE | Pak Harjo | Opus | Kode vs blueprint, bug logika/API | `/validate-tiket --tim` |
| Spesialis eskalasi | Eyang Wiryo | Fable | Hanya saat pemicu | `/validate-tiket --tim` |
| PjM | Bu Sumi | Sonnet | Tiket terkait, PR terbuka, risiko bentrok | `/validate-tiket --tim` |
| Reviewer | Mbah Karto | Opus | Keamanan sisi klien, performa, a11y, logika vs AC | `/develop-tiket` |
| Release | Sutini | Haiku | PR/MR, deploy, komentar, geser tiket, tag | `/develop-tiket`, `/rilis-tiket`, `/branch-manager` |
| Coder | Maman, Ujang, Tarjo, Asep, Parmin | Sonnet | Kode + tes (TDD) di branch tiketnya | `/develop-tiket` |
| QA | Paijo, Euis, Ningsih | Sonnet | Playwright per ukuran layar, axe, Schemathesis, Pact, regresi | `/develop-tiket`, `/branch-manager` |
| Auditor | Cecep, Dadang, Sarip | Opus | Kode, log, reproduksi | `/audit-issue` |
| Analis | Bu Lastri | Opus | Lampiran vs kode vs halaman | `/audit-issue` |

- Claude Code: agen tambahan selalu **teammate**: tampil sebagai panel split di tab SPV dengan label `@<Nama>-<Label><n>` (mis. `@Paijo-QA1`). Butuh teammate mode (`claude --teammate-mode auto`).
- Tiap peran menjalankan skill internal yang disebut di tugasnya (mis. Coder → `/implement-tdd`, QA → `/test-browser` + `/check-a11y`, Reviewer → `/review-code`).
- Agen coding lain: peran yang sama dijalankan sebagai subagent bawaan agen itu (brief dari file peran `agents/<peran>.md`); tanpa subagent → satu agen menjalankan semua peran berurutan (mode solo). Model per peran hanya berlaku di Claude Code.
- Model diubah di `~/.agent-workflow/frontend-kit/agents/<peran>.md` (symlink ke `agents/` di repo ini).

---
[← kembali ke README](../README.md)
