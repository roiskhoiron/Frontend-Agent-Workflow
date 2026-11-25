# Akun uji dan kredensial

Isi kredensial **tidak pernah** ditulis ke dokumen laporan, tiket, PR/MR, commit, log laporan, memory project, atau `CLAUDE.md`. Di laporan cukup sebut nama kunci (mis. `QA_USER1`).

## Urutan cari
1. `.env.agent.local` di root project (template dari kit ini)
2. `.env.local`, `.env.development.local`, `.env.test.local`
3. `.env` yang di-gitignore

Cek gitignore sebelum memakai file: `git check-ignore -q <file>`. File berisi kredensial **tidak** di-ignore → jangan dipakai, jangan tampilkan isinya, berhenti dan tanya.

## Belum ada kredensial
Berhenti dan tanya (`rules.md`) dengan saran:
1. Tambahkan `.env.agent.local` ke `.gitignore` **lebih dulu**.
2. Salin template `$FRONTEND_WORKFLOW_DIR/templates/env.agent.local` ke root project sebagai `.env.agent.local`.
3. User mengisi nilainya sendiri.

Kunci di template:
| Kunci | Isi |
|---|---|
| `QA_ENV` | `dev` atau `staging` (env akun uji) |
| `QA_BASE_URL` | URL situs yang diuji bila bukan server lokal |
| `QA_API_BASE_URL` | URL API dev/staging |
| `QA_USER1_EMAIL`, `QA_USER1_PASSWORD` | akun uji 1 |
| `QA_USER2_EMAIL`, `QA_USER2_PASSWORD` | akun uji 2 (tambah `QA_USER3_...` bila perlu) |
| `QA_LIVE_USER1_EMAIL`, `QA_LIVE_USER1_PASSWORD` | opsional: akun uji production khusus smoke live (baca saja) |

## Pemakaian
- Kunci akun: `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/lock.sh" acquire account:qa.user1 <owner>`; lepas setelah selesai (`browser.md` → Akun uji).
- Kredensial dibaca saat dipakai: `set -a; . ./.env.agent.local; set +a` di panggilan Bash yang menjalankan Playwright, lalu spec membaca `process.env.QA_USER1_EMAIL`. Tidak disalin ke file lain yang ter-track, tidak di-`echo`.
- Sesi login Playwright (`storageState`) disimpan di `${TMPDIR:-/tmp}/qa/<KODE>/auth-<akun>.json`, tidak di repo; dihapus setelah selesai.

## Data uji
- Hanya di **dev/staging**; `QA_ENV`/URL mengarah ke production → berhenti (kecuali smoke live baca saja dengan akun `QA_LIVE_*`).
- Semua data yang dibuat diawali kode tiket, mis. `PROJ-1234 Alamat Uji`, `proj1234+a@example.com`; di regresi rilis berawalan versi (`v1.4.0 ...`).
- Catat data yang dibuat di bagian Temuan laporan (tanpa password).
