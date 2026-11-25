# Pagar keamanan

Dua lapis: **guard** (hook `hooks/guard-frontend.sh`, memblokir sebelum perintah jalan, aktif di mode Diawasi maupun Otonom) dan **aturan berhenti-dan-tanya** (ditaati agen, `skills/_shared/rules.md`).

## Diblokir guard
| Yang diblokir | Kenapa |
|---|---|
| `git push` ke selain `origin` (kecuali tag `vX.Y.Z` eksplisit ke `origin`/`upstream`) | Upstream hanya lewat PR/MR |
| Force-push / hapus `main`, `master`, `develop` | Branch terlindungi |
| `rm -r` di luar folder project | Kecuali artefak web yang bisa dibuat ulang (`node_modules`, `.next`, `dist`, `build`, `.turbo`, `.vite`, `coverage`, `playwright-report`, `test-results`, ...) di worktree lain repo yang sama atau folder di `build-roots.txt`; isi `/tmp/qa` bebas |
| Transisi Jira ke status yang tidak ada di `jira-transitions.json` | Done hanya manusia; berlaku untuk semua nama connector Atlassian |
| Edit/Write di worktree primary (repo dengan worktree tambahan) | Kerja hanya di workspace domain / worktree tiket |
| `git worktree` di luar folder sejajar, `remove --force`, `move`, hapus selain worktree tiket/rilis | Worktree milik user dan worktree dokumen tidak dihapus agen |
| Orca: tab/terminal/agen baru, project/repo/workspace baru | Agen tambahan = teammate |
| **Mode audit** (`/audit-issue`): semua tulisan git, `glab` tulis, tulisan Atlassian, edit file di luar `/tmp/audit`, dan deploy/publish (`vercel`, `netlify deploy`, `firebase deploy`, `wrangler deploy`, `npm publish`, ...) | Audit hanya-baca |

Pesan guard selalu diawali "DIBLOKIR oleh guard:" dan menyebut cara yang benar. Agen tidak mencari jalan memutar.

## Agen berhenti dan bertanya
1. Deploy ke **production** (izin eksplisit per deploy).
2. Sebelum memulai hotfix (sementara manual).
3. Kredensial tidak ditemukan, atau file kredensial tidak di-gitignore.
4. Dua fix hotfix bentrok.
5. Endpoint di server tujuan **Belum ada** / **Beda kontrak** sebelum deploy staging/production.
6. Gerbang validasi: belum pernah divalidasi, **Tidak layak**, atau dokumen berubah sejak validasi.
7. Merge PR tiket, PR revert, dan pilihan rilis (Konfirmasi / Tolak / Ikuti rekomendasi).

Cara tanya: ringkasan temuan + **satu saran**. Teammate bertanya lewat SPV.

## Data dan kredensial
- Akun uji dari `.env.agent.local` (di-gitignore); isinya tidak pernah ditulis ke laporan, tiket, PR, atau commit.
- Data uji hanya di dev/staging, berawalan kode tiket. Production hanya smoke live baca saja.
- Kunci (`bin/lock.sh`): satu akun, satu agen, satu waktu; satu port per worktree; satu deploy per env.

---
[← kembali ke README](../README.md)
