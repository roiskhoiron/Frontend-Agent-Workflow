---
name: deploy-preview
description: Skill internal workflow Frontend. Membuat deploy pratinjau untuk branch tiket (atau batch) di hosting dari memory project - otomatis per PR atau lewat CLI - dan mencatat URL, hash commit, dan env API-nya. Menggantikan /build-app di Mobile. Dipakai /develop-tiket langkah 6 (Release).
argument-hint: "KODE... [--env dev|staging]"
---
Deploy pratinjau `$ARGUMENTS`. Baca: `deploy-release.md` (Jenis deploy, Hosting), `rules.md`.

## Langkah
1. **Hosting** dari memory project (penyedia, pratinjau otomatis per PR atau perintah CLI, pemetaan env → variabel env API). Belum ada → baca `vercel.json`/`netlify.toml`/`firebase.json`/`wrangler.toml`/workflow CI, saran, tanya sekali, simpan.
2. **Otomatis per PR:** pastikan commit terakhir branch tiket sudah di-push; tunggu status check deploy di PR (`gh pr checks <n> --watch --interval 30`, batas 15 menit) lalu ambil URL dari check/komentar bot/`gh api repos/<upstream>/deployments`. Gagal → potongan log dan lapor.
3. **CLI:** dari worktree tiket (atau checkout domain untuk `--batch`), dengan env API sesuai `--env`: mis. `vercel deploy`, `netlify deploy --dir <out>`, `wrangler pages deploy <out> --branch <branch tiket>`, `firebase hosting:channel:deploy <KODE>`. **Tidak pernah** flag/perintah production (`--prod`, `--branch <primary>`, `firebase deploy`).
4. **Env staging:** hanya bila project punya pemetaan env staging dan Matriks env staging tidak **Belum ada**/**Beda kontrak**.
5. Cek URL: halaman utama tiket terbuka (HTTP 200, tanpa console error fatal) dengan `page-shot.mjs` di ukuran desktop; simpan screenshot ke `${TMPDIR:-/tmp}/qa/<KODE>/pratinjau.png`.

## Keluaran
Tabel `KODE | URL pratinjau | hash | env + base URL API | cara (otomatis/CLI)`.

## Tidak boleh
Deploy production; menulis token hosting ke file/laporan; deploy dari branch batch ke URL yang dipakai bersama tanpa disebut di rencana.
