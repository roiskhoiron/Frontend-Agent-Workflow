---
name: prepare-release-pr
description: Skill internal workflow Frontend. Membuat atau memperbarui Draft PR rilis dari branch upstream protected ke primary (tanpa push branch), berisi link dokumen rilis, sha rilis, tabel perubahan, dan catatan merge commit. Dipakai /branch-manager (Release).
argument-hint: "<vX.Y.Z> <link dokumen rilis>"
---
PR rilis `$ARGUMENTS`. Baca: `deploy-release.md` (Rilis).

## Langkah
1. Body di file sementara `${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/pr-body.md`: link dokumen rilis, `<sha-rilis>`, tabel perubahan, catatan **"merge dengan merge commit, bukan squash"**, catatan deploy production (manual setelah tag, atau otomatis oleh hosting saat merge).
2. PR rilis yang terbuka sudah ada (`gh pr list --repo <upstream> --base <primary> --head <protected> --state open`)? Ya → `gh pr edit <N> --repo <upstream> --title "Rilis vX.Y.Z" --body-file <body>` / `glab mr update <N> -R <upstream> --title ... --description "$(cat <body>)"`. Belum → `gh pr create --repo <upstream> --base <primary> --head <protected> --draft --title "Rilis vX.Y.Z" --body-file <body>` / `glab mr create -R <upstream> --source-branch <protected> --target-branch <primary> --draft ...`.

## Keluaran
Link PR rilis + nomor.

## Tidak boleh
Push branch ke upstream; merge PR rilis; menandai siap tanpa diminta.
