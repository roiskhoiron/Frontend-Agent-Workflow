# Frontend-Agent-Workflow

Tim agen Claude Code + Orca untuk mengerjakan tiket Jira di proyek **frontend web**: dari cek tiket, menulis kode, uji di browser (Playwright, per ukuran layar, aksesibilitas), deploy pratinjau, sampai PR/MR dan rilis. Kerangkanya sama dengan [kit Mobile](https://github.com/roiskhoiron/mobiledev-agent-workflow); yang berubah hanya hal khas platform: device → browser, build aplikasi → deploy, Maestro → Playwright.

Status: **v1 (kerangka lengkap)**, siap uji coba di tiket nyata. Rancangan: [docs/design-summary.md](docs/design-summary.md).

## Daftar isi
1. [Mulai cepat](#mulai-cepat) dan [istilah penting](#istilah-penting) (di halaman ini)
2. [Alur kerja + skill set](docs/alur-kerja.md): lima perintah, semua flag, dan skill internal tiap flow
3. [Tim agen](docs/tim-agen.md): peran, nama, model
4. [Pagar keamanan](docs/pagar-keamanan.md): yang diblokir guard, kapan agen berhenti dan bertanya
5. [Alat (tools) + MCP](docs/alat.md): skrip `bin/`, alat browser, MCP, pembersihan otomatis
6. [Pasang di komputer lain](docs/pasang.md)
7. [Masalah umum](docs/masalah-umum.md)
8. [Rancangan dan keputusan](docs/design-summary.md)

## Mulai cepat

| Perintah | Gunanya | Jalankan dari |
| --- | --- | --- |
| `/validate-tiket KODE... [--solo\|--tim]` | Cek tiket layak dikerjakan; bug direproduksi di browser dengan screenshot bertanda. Hasil: laporan + komentar keputusan | mana saja |
| `/develop-tiket KODE... [--solo\|--tim] [--batch\|--separate] [--uat]` | Rencana, kode (TDD), review, uji Playwright per ukuran layar + aksesibilitas, deploy pratinjau, PR/MR, komentar, Ready To Review | workspace domain |
| `/rilis-tiket KODE...` | Tindak lanjut feedback QA per tiket: kembalikan ke Todo, deploy staging/production atas permintaan, atau audit + merge PR tiket | root project atau domain |
| `/branch-manager --rilis KODE` | Rilis per versi: tracing perubahan, regresi penuh di staging, dokumen rilis, PR rilis, tag, deploy production (izin), smoke live | root project atau domain |
| `/audit-issue "teks" [--solo\|--tim] [lampiran...]` | Telusuri keluhan yang belum jadi tiket, **hanya-baca** | mana saja |

```text
/validate-tiket WEB-1234
/develop-tiket WEB-1234 WEB-1240 --tim
/develop-tiket WEB-1300 --solo --separate --uat
/audit-issue "tombol bayar tidak muncul di Safari iPhone" --solo
/rilis-tiket WEB-1234
/branch-manager --rilis WEB-1400
```

Pasang: `./install.sh` (detail di [docs/pasang.md](docs/pasang.md)). Tes kit: `bash tests/run.sh`.

## Istilah penting

| Istilah | Penjelasan sederhana |
| --- | --- |
| **Skill flow** | Lima perintah di atas. Isinya urutan langkah; tiap langkah menjalankan satu **skill internal** |
| **Skill internal** | Skill kecil dengan satu tugas (mis. `/read-ticket`, `/test-browser`, `/deploy-preview`). Tidak saling memanggil, jadi urutan kerja selalu terlihat dari skill flow |
| **SPV** | Agen "mandor": membaca tiket, membagi tugas, memutuskan tiket selesai |
| **Workspace domain** | Workspace Orca yang kamu buka untuk kerja kode. Root project hanya untuk audit, tanya, validasi, dan rilis |
| **Worktree tiket** | Salinan kerja repo khusus satu tiket, folder `<repo>-<nomor>` di sebelah checkout domain, dengan port dev server sendiri |
| **Branch batch** | Branch lokal tempat semua tiket `--batch` digabung untuk satu kali uji. Tidak pernah di-push |
| **Deploy pratinjau** | Salinan situs dari branch tiket di hosting (Vercel/Netlify/...) untuk dicoba orang lain. Pengganti "build dev" di Mobile |
| **Matriks env** | Status tiap endpoint tiket di server dev / staging / production |
| **Matriks browser** | Browser dan ukuran layar yang wajib diuji (default Chromium: desktop, tablet, ponsel) |
| **Guard** | Hook `guard-frontend.sh` yang memblokir perintah berbahaya sebelum dijalankan |
| **Memory project** | Catatan per project di Claude Code (branch, hosting, server API, lokasi dokumen). Ditanya sekali, lalu disimpan |
| **Downstream / upstream** | `origin` = fork kita (boleh push branch); `upstream` = repo utama (hanya lewat PR/MR) |
| **TC / AC** | Test case / acceptance criteria tiket. Hasil TC: Lulus, Gagal, atau Tertahan (dengan alasan) |

## Isi repo

| Folder | Isi |
| --- | --- |
| `skills/<flow>/SKILL.md` | Lima skill flow: `/validate-tiket`, `/develop-tiket`, `/rilis-tiket`, `/branch-manager`, `/audit-issue` |
| `skills/<internal>/SKILL.md` | 34 skill internal (daftar di [docs/alur-kerja.md](docs/alur-kerja.md#skill-set-di-tiap-flow)) |
| `skills/_shared/` | Aturan bersama: `rules.md`, `browser.md`, `credentials.md`, `deploy-release.md`, `report-format.md` |
| `agents/` | 15 peran agen (model, tugas, larangan) |
| `bin/` | Skrip pembantu (tabel di [docs/alat.md](docs/alat.md)) |
| `hooks/guard-frontend.sh` | Pagar keamanan |
| `templates/` | Blok `CLAUDE.md` global dan template akun uji `.env.agent.local` |
| `launchd/` | Jadwal pembersihan berkala (macOS) |
| `tests/` | Tes skrip, guard, skill, dan dokumen: `bash tests/run.sh` |
| `docs/` | Panduan lengkap |

## Merawat dokumen ini

README + `docs/` adalah pintu masuk pemula. README tetap singkat; detail di `docs/<topik>.md`. **Setiap perubahan workflow atau alat wajib memperbarui README atau halaman `docs/` yang sesuai di commit yang sama.** `tests/readme_test.sh` gagal bila ada perintah/skill, skrip `bin/`, atau MCP yang belum disebut di README maupun `docs/*.md`. Detail teknis tetap di `skills/` dan `agents/`.
