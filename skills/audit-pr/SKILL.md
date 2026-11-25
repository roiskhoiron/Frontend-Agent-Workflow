---
name: audit-pr
description: Skill internal workflow Frontend. Memeriksa PR/MR tiket sebelum merge - tiket Done, approved, CI hijau, isi diff sesuai tiket, Matriks env production sesuai kontrak - serta kebutuhan PR revert-dari-revert. Dipakai /rilis-tiket (Release).
argument-hint: "KODE <nomor PR/MR>"
---
Audit PR/MR `$ARGUMENTS` (baca saja). Baca: `deploy-release.md` (Merge PR tiket, Rilis).

## Langkah
1. Syarat:
   | Syarat | Cara cek |
   |---|---|
   | Tiket Done + punya PR/MR | operasi **Baca tiket** (`board.md`), `gh pr view <n> --repo <upstream>` |
   | Approved | `gh pr view <n> --json reviewDecision` / `glab mr view <n>` |
   | CI hijau | `gh pr checks <n>` / status pipeline MR |
   | Diff sesuai tiket | baca diff vs AC; `"$FRONTEND_WORKFLOW_DIR/bin/manifest-check.sh" <base> <head> <KODE>` |
   | Matriks env production **Sesuai kontrak** | hasil Matriks env terbaru untuk production |
2. **Revert sebelumnya:** `gh pr list --repo <upstream> --state merged --limit 200 --json headRefName --jq '.[].headRefName' | grep -E '^(un)?revert/<KODE>-[0-9]+$'` (GitLab: `glab mr list --merged -F json`, `source_branch`). Ada `revert/<KODE>-<n>` tanpa `unrevert/<KODE>-<n>` merged untuk `<n>` tertinggi → **perlu unrevert** `<n>` sebelum PR tiket.
3. Strategi merge dari memory project; belum tercatat → **perlu keputusan**.

## Keluaran
Tabel syarat → lolos/gagal + bukti; **siap merge** / **tidak** + saran; perlu unrevert (ya/tidak, `<n>`).

## Tidak boleh
Merge (flow yang merge setelah "ya"); approve PR.
