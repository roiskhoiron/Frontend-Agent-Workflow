---
name: release-trace
description: Skill internal workflow Frontend. Menelusuri tiap commit rilis (primary..protected) ke PR/MR, KODE tiket, programmer, dan status tiket; menandai commit tak terlacak, tiket belum Done, dan PR revert. Dipakai /branch-manager.
argument-hint: "<PREFIX...>"
---
Tracing rilis untuk prefix `$ARGUMENTS`. Baca: `deploy-release.md` (Rilis).

## Langkah
1. `git fetch upstream origin`; `"$FRONTEND_WORKFLOW_DIR/bin/release-trace.sh" upstream/<primary> upstream/<protected> <PREFIX>...`.
   - Exit 3 → hasil **berhenti: hotfix belum di-back-merge**. Exit 2 → perbaiki ref (memory project), ulangi. Exit 0/1 → simpan TSV.
   - Catat `<sha-rilis>` = `git rev-parse upstream/<protected>` saat itu.
2. Tiap baris TSV (`sha7 pr kode author subject`):
   - PR/MR asal (`gh pr view <N> --repo <upstream> --json headRefName,author,url,title` / `glab mr view <N>`); `pr=-` → `gh api repos/<upstream>/commits/<sha>/pulls`; tetap tidak ada → tandai.
   - KODE: kolom `kode`; `-` → judul PR, lalu `headRefName`; tetap tidak ada → **tak terlacak**.
   - Programmer = pembuat PR + author commit (beda → keduanya).
   - Status tiket tiap KODE (operasi **Baca tiket**, `board.md`).
   - `revert: <KODE> keluar dari rilis ...` dan pasangan unrevert-nya → **dikeluarkan**.

## Keluaran
`${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/trace.md`: `<sha-rilis>`, tabel `KODE | Ringkasan | Branch | PR/MR | Programmer | Status tiket`, daftar tak terlacak, belum Done, dikeluarkan.

## Tidak boleh
Mengubah branch/tag; memindah tiket.
