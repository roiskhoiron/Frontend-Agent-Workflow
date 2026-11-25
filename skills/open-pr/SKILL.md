---
name: open-pr
description: Skill internal workflow Frontend. Membuat Draft PR/MR tiket di awal pengerjaan, mengembalikan PR/MR yang ada ke Draft untuk revisi, atau memperbarui isi dan menandainya siap review di akhir. Dipakai /develop-tiket (Release).
argument-hint: "KODE <draft|revisi|siap> <worktree>"
---
PR/MR untuk `$ARGUMENTS`. Baca: `deploy-release.md` (PR/MR), `rules.md` (Git).

## Mode `draft` (tiket tanpa jejak, sebelum Coder mulai)
1. Branch belum beda dari base → `git -C <worktree> commit --allow-empty -m "chore: <KODE> mulai pengerjaan"`.
2. `git -C <worktree> push -u origin <branch tiket>`.
3. `gh pr create --repo <upstream> --base <protected> --head <fork>:<branch> --draft --title "<KODE>: <judul>" --body-file <body>` / `glab mr create --draft ...`. Isi body: link rencana, Acuan tiket, Matriks env. Host dari `git remote get-url upstream`.

## Mode `revisi` (tiket dengan jejak, PR/MR belum merged)
`gh pr ready <n> --undo` / `glab mr update <n> --draft`; tidak membuat PR/MR baru.

## Mode `siap`
1. Push terakhir `git -C <worktree> push origin <branch tiket>`.
2. Perbarui body: ringkasan, link rencana dan laporan uji, Acuan tiket, Matriks env, deploy pratinjau (URL + hash + env API), daftar micro-interaction, perubahan dependensi.
3. `gh pr ready <n>` / `glab mr update <n> --ready`. Belum ada Draft (cadangan) → buat seperti mode `draft` tanpa `--draft`.

## Keluaran
Link PR/MR + status (draft/siap).

## Tidak boleh
Push ke selain `origin`; force-push; PR dari branch batch; merge; kredensial di body.
