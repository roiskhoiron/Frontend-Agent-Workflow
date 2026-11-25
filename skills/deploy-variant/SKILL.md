---
name: deploy-variant
description: Skill internal workflow Frontend. Deploy ke staging (atas permintaan QA atau untuk regresi rilis), dan ke production hanya setelah izin eksplisit user per deploy; antre lewat kunci deploy:<env>, cek Matriks env dulu. Menggantikan /build-variant di Mobile. Dipakai /rilis-tiket dan /branch-manager (Release).
argument-hint: "<staging|production> <KODE|vX.Y.Z> <ref atau sha>"
---
Deploy `$ARGUMENTS`. Baca: `deploy-release.md`, `rules.md` (Selalu berhenti dan tanya).

## Langkah
1. **Isi:** ref yang di-deploy memang memuat tiket/rilis itu (`git merge-base --is-ancestor` atau `manifest-check.sh`); tidak → tanya.
2. **Matriks env** server tujuan sudah dicek di langkah sebelumnya: ada **Belum ada**/**Beda kontrak** → berhenti dan tanya.
3. **Production:** minta **izin eksplisit** di chat (ringkasan: versi, sha, apa yang berubah, hasil regresi) dan tunggu "ya". Tanpa "ya" → tidak ada deploy. Hosting men-deploy production otomatis dari `<primary>` → tidak ada perintah deploy di sini; catat bahwa deploy terjadi saat manusia merge.
4. Kunci: `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/lock.sh" acquire deploy:<env> <owner>`; dipegang tiket lain → tunggu atau tanya.
5. Worktree: worktree tiket `<repo>-<nomor>` (dibuat ulang dari `origin/<branch tiket>` bila sudah dihapus: branch lokal ada → tanpa `-b` lalu `merge --ff-only`; belum → `-b <jenis>/<KODE> origin/<branch tiket>`), atau worktree rilis detached `<repo>-rilis-vX.Y.Z` di `<sha-rilis>`. Pasang dependensi dari lockfile, build dengan env API server tujuan.
6. Deploy dengan perintah hosting dari memory project untuk env itu; catat URL, hash (`git rev-parse --short HEAD`), env + base URL API. Lepas kunci.
7. Cek URL dengan `page-shot.mjs` (HTTP 200, tanpa console error fatal).
8. Worktree tiket yang dibuat ulang → hapus lagi bila bersih dan sudah di-push (tanpa `--force`).

## Keluaran
`env | URL | hash | env API | waktu`.

## Tidak boleh
Production tanpa "ya"; token hosting di file/laporan; deploy commit yang belum dilacak (`<protected>` maju dari `<sha-rilis>` → lapor).
