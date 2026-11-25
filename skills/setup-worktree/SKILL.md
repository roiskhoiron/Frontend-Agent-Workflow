---
name: setup-worktree
description: Skill internal workflow Frontend. Mengenali domain Orca dan checkout domain, membuat atau memakai ulang worktree + branch tiket <repo>-<nomor> dari base remote terbaru, mengunci checkout, dan memasang dependensi dari lockfile. Dipakai /develop-tiket.
argument-hint: "KODE [jenis: feature|fix|hotfix|chore|docs]"
---
Siapkan worktree tiket `$ARGUMENTS`. Baca: `rules.md` (Lokasi, Workspace & worktree).

## Langkah
1. **Domain:** `$ORCA_WORKTREE_ID` → `orca worktree list --json` → `displayName`, `path`, `isMainWorktree`. Root project → hasil **berhenti: jalankan dari workspace domain**. Tanpa Orca → checkout saat ini, kecuali itu worktree primary repo yang punya worktree lain (berhenti).
2. **Checkout domain** (git worktree workspace, atau `<path>/<repo>-<slug>` untuk workspace folder; belum ada → buat seperti `rules.md`). Kunci `checkout:<path>` dengan `lock.sh`; dipegang batch lain → cadangan solo/tanya.
3. **Branch project** dari memory (`<primary>`, `<protected>`, remote, strategi merge). Belum ada → kumpulkan saran (`git remote -v`, `git ls-remote --symref upstream HEAD`, `git branch -r`), tanya sekali, simpan.
4. **Base:** `git fetch upstream` (+ `origin`); feature/fix/chore/docs → `upstream/<protected>`; hotfix → tanya (manual). Catat `git rev-parse --short <base>`.
5. **Worktree tiket** `../<repo>-<nomor>` (nomor = angka KODE), path ditulis literal:
   - Tanpa jejak: `git -C <checkout domain> worktree add ../<repo>-<nomor> -b <jenis>/<KODE> <base>`.
   - Ada jejak (branch/PR belum merged): pakai branch yang ada; worktree sudah ada → pakai; tertinggal (`git rev-list --count HEAD..<base>` > 0) → lapor jumlah commit, tanya rebase/merge/lanjut.
   - PR sudah merged: branch baru `<jenis>/<KODE>-r<n>` dari base terkini.
6. Kunci `checkout:<path worktree tiket>`.
7. **Framework** dari memory project (package manager, perintah dev/build/preview/test/lint/typecheck/e2e). Belum ada → baca `package.json` + lockfile, saran, tanya sekali, simpan.
8. Pasang dependensi dengan lockfile (`npm ci` / `pnpm install --frozen-lockfile` / `yarn install --immutable`). Gagal → lapor potongan galat dan tanya.

## Keluaran
Tabel `KODE | worktree | branch | base + hash | jejak | dependensi` + kunci yang dipegang.

## Tidak boleh
`orca worktree create`, project/workspace Orca baru, worktree di luar folder sejajar, `--force`, base dari branch lokal yang bisa basi.
