# Rancangan dan keputusan

Sumber rancangan: dokumen **Draft: Agent Workflow Delivery Frontend Web** (Claude Docs), yang merujuk dokumen **Rancangan Workflow Agen Jira** (workflow Mobile) untuk bagian yang sama. Repo ini mengimplementasikan draft itu.

## Yang sama dengan Mobile (dipakai tanpa perubahan)
Alur kanban; tim agen dan modelnya; mode Diawasi/Otonom dengan pagar aktif di keduanya; worktree Orca bertingkat (primary, domain, tiket, coder); gerbang validasi dan Acuan tiket; flag `--solo`, `--tim`, `--batch`, `--separate`, `--uat`; alur branch rilis (PR tiket ke protected, PR rilis ke primary dengan tag, merge oleh manusia); `/audit-issue` hanya-baca.

## Yang berbeda dari Mobile
| Bagian | Mobile | Frontend web (repo ini) |
|---|---|---|
| Tempat reproduksi dan uji | Device fisik, emulator, simulator | Browser: Playwright (+ browser tertanam Orca untuk melihat) |
| Alat uji alur layar | Maestro, XCUITest | Playwright |
| Uji API dan kontrak | Schemathesis, Pact | Sama (frontend = konsumen Pact) |
| Tanda di screenshot | Koordinat elemen di device | Posisi elemen di halaman (`page-shot.mjs` → `annotate.py`) |
| Variasi yang diuji | Android dan iOS | Browser + ukuran layar dari matriks |
| Hasil build | Build dev/beta/prod ke Firebase/TestFlight | Deploy pratinjau, staging, production |
| Nomor build | Angka tiket, lalu terakhir + 1 | Tidak ada; hash commit dan tag `vX.Y.Z` |
| Sumber daya bersama | Device (dikunci) | Port dev server dan akun uji (dikunci); deploy per env |
| Akun uji | `local.properties`, `.xcconfig` | `.env.agent.local` yang tidak ikut git |
| Berhenti dan bertanya | Upload build prod | Deploy ke production |
| Pembersihan berkala | DerivedData, Gradle, APK/IPA | Laporan Playwright lama, cache build, `node_modules` worktree tiket nganggur, cache npm/pnpm/yarn |
| Gate tambahan | — | Aksesibilitas dan tampilan responsif |
| Dokumen agen | Claude Docs | Markdown di `docs/` (default), Claude Docs bila dipilih |

## Keputusan implementasi (dibuat Claude, koreksi bila tidak cocok)
| Keputusan | Alasan |
|---|---|
| 34 skill internal diimplementasikan sebagai skill terpisah; skill flow hanya berisi urutan + gerbang; `tests/skills_test.sh` memastikan skill internal tidak saling memanggil | Mengikuti "Skill set di tiap flow"; urutan kerja terlihat dari flow |
| Nama folder bersama `_frontend-workflow-shared`, variabel `FRONTEND_WORKFLOW_DIR`, guard `guard-frontend.sh` | Tidak menimpa kit Mobile; state `~/.agent-workflow` (kunci, transisi Jira) tetap dipakai bersama |
| `install.sh` menolak bila nama perintah/agen sudah dipasang kit lain, kecuali `--force` | Nama perintah sama dengan Mobile; mencegah tertimpa diam-diam |
| `repo-markdown` = worktree `<repo>-docs` di branch `agent-docs` milik `origin`, link = URL file di forge | Validasi terjadi sebelum ada branch tiket, worktree primary tidak boleh diedit, dan laporan butuh link untuk komentar tiket |
| Planner menulis rencana ke file lokal; SPV yang menerbitkan (`/write-report`) | Planner tetap tanpa akses tulis ke luar, apa pun platform dokumentasinya |
| `--batch`: satu build produksi + server preview lokal untuk QA (bukan dev server) | Setara "satu build untuk semua tiket" di Mobile, dan lebih dekat ke hasil deploy |
| Deploy production setelah tag; hosting yang otomatis deploy dari `<primary>` dianggap deploy saat manusia merge | Agen tidak pernah merge PR rilis; izin tetap eksplisit |
| Guard tidak memblokir deploy production di mode biasa (hanya di mode audit) | Sama dengan Mobile: upload prod = aturan berhenti-dan-tanya; penanda izin yang bisa dibuat agen sendiri tidak memberi keamanan nyata |
| Port default 4100–4199, kunci `port:<n>` | Agen paralel tidak saling menimpa dev server |
| Gerbang a11y = pelanggaran critical/serious **baru** di area tiket | Pelanggaran lama tidak memblokir tiket yang tidak menyentuhnya |
| Matriks browser default Chromium desktop 1440×900, tablet 768×1024, ponsel 390×844 | Angka awal, ditanya sekali per project |

## Yang masih terbuka (dijawab per project lewat memory project)
- [ ] Framework dan pustaka komponen yang dipakai?
- [ ] Hosting dan cara membuat deploy pratinjau per PR/MR?
- [ ] Browser dan ukuran layar mana yang wajib didukung?
- [ ] Apakah design system sudah tersedia sebagai kode?
- [ ] Skill khusus framework apa yang menggantikan `android-cli` dan `kotlin-agent-skills`? (belum ada di repo ini)
- [ ] Skill bersama (`/read-ticket`, `/write-report`, ...) dipindah ke repo bersama untuk workflow Backend/DevOps?

---
[← kembali ke README](../README.md)
