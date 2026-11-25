---
name: tag-release
description: Skill internal workflow Frontend. Setelah PR rilis di-merge manusia, memeriksa commit merge (merge commit, parent kedua = sha rilis) lalu membuat tag beranotasi vX.Y.Z dan push ke upstream dan origin. Dipakai /branch-manager (Release).
argument-hint: "<vX.Y.Z> <nomor PR rilis> <sha-rilis>"
---
Tag rilis `$ARGUMENTS`. Baca: `deploy-release.md` (Rilis), `rules.md` (Git).

## Langkah
1. `gh pr view <N> --repo <upstream> --json state,mergeCommit --jq '.state + " " + (.mergeCommit.oid // "")'` / `glab mr view <N>`. Belum merged → hasil **belum merged** (ingatkan user, berhenti).
2. `git fetch upstream`; `git rev-list --parents -n1 <merge commit>`:
   - Tanpa parent kedua (squash) → **tanya** sebelum tag.
   - Parent kedua ≠ `<sha-rilis>` → **ulang tracing** sebelum tag.
   - Sama → lanjut.
3. Tag belum ada (`git ls-remote --tags upstream vX.Y.Z` kosong); sudah ada → **berhenti**, tag tidak pernah ditimpa.
4. `git tag -a vX.Y.Z <merge commit> -m "Rilis vX.Y.Z"`, lalu `git push upstream vX.Y.Z` dan `git push origin vX.Y.Z` (tulis nama tag eksplisit).

## Keluaran
Tag + commit + link tag di forge.

## Tidak boleh
`--force`, hapus tag, `git push --tags`, tag di commit selain merge PR rilis.
