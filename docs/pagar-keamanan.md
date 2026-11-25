# Pagar keamanan

Dua lapis: **guard** (hook `hooks/guard-frontend.sh`, memblokir sebelum perintah jalan, aktif di mode Diawasi maupun Otonom) dan **aturan berhenti-dan-tanya** (ditaati agen, `skills/_shared/rules.md`).

## Diblokir guard
| Yang diblokir | Kenapa |
|---|---|
| `git push` ke selain `origin` (kecuali tag `vX.Y.Z` eksplisit ke `origin`/`upstream`) | Upstream hanya lewat PR/MR |
| Force-push / hapus `main`, `master`, `develop` | Branch terlindungi |
| `rm -r` di luar folder project | Kecuali artefak web yang bisa dibuat ulang (`node_modules`, `.next`, `dist`, `build`, `.turbo`, `.vite`, `coverage`, `playwright-report`, `test-results`, ...) di worktree lain repo yang sama atau folder di `build-roots.txt`; isi `/tmp/qa` bebas |
| Geser status tiket ke nilai yang tidak ada di `board-status.json` (id transisi Jira, opsi GitHub Projects, label status GitHub/GitLab) | Done hanya manusia |
| Menutup issue (`gh issue close`, `glab issue close`, MCP `state: closed`), hapus item project | Menutup issue = Done |
| Edit/Write di worktree primary (repo dengan worktree tambahan) | Kerja hanya di workspace domain / worktree tiket |
| `git worktree` di luar folder sejajar, `remove --force`, `move`, hapus selain worktree tiket/rilis | Worktree milik user dan worktree dokumen tidak dihapus agen |
| Orca: tab/terminal/agen baru, project/repo/workspace baru | Agen tambahan = teammate |
| **Mode audit** (`/audit-issue`): semua tulisan git, `glab` tulis, tulisan ke platform tiket (`gh issue/project`, `gh api` non-GET, Atlassian, MCP GitHub/GitLab), edit file di luar `/tmp/audit`, dan deploy/publish (`vercel`, `netlify deploy`, `firebase deploy`, `wrangler deploy`, `npm publish`, ...) | Audit hanya-baca |

Tidak tertangkap guard (tanggung jawab agen): `gh api graphql` yang mengubah field project, dan `Closes #n` di PR. Karena itu PR hanya menulis `Refs #n`.

Pesan guard selalu diawali "DIBLOKIR oleh guard:" dan menyebut cara yang benar. Agen tidak mencari jalan memutar.

## Agen berhenti dan bertanya
1. Platform tiket belum tercatat (tidak ada default): agen bertanya dulu.
2. Deploy ke **production** (izin eksplisit per deploy).
3. Sebelum memulai hotfix (sementara manual).
4. Kredensial tidak ditemukan, atau file kredensial tidak di-gitignore.
5. Dua fix hotfix bentrok.
6. Endpoint di server tujuan **Belum ada** / **Beda kontrak** sebelum deploy staging/production.
7. Gerbang validasi: belum pernah divalidasi, **Tidak layak**, atau dokumen berubah sejak validasi.
8. Merge PR tiket, PR revert, dan pilihan rilis (Konfirmasi / Tolak / Ikuti rekomendasi).

Cara tanya: ringkasan temuan + **satu saran**. Teammate bertanya lewat SPV.

## Data dan kredensial
- Akun uji dari `.env.agent.local` (di-gitignore); isinya tidak pernah ditulis ke laporan, tiket, PR, atau commit.
- Data uji hanya di dev/staging, berawalan kode tiket. Production hanya smoke live baca saja.
- Kunci (`bin/lock.sh`): satu akun, satu agen, satu waktu; satu port per worktree; satu deploy per env.

---
[← kembali ke README](../README.md)
