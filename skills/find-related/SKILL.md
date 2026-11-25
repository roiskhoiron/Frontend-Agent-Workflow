---
name: find-related
description: Skill internal workflow Frontend. Mencari tiket terkait atau bertabrakan (link, blocking, epic/sprint, tiket tak ter-link yang menyentuh halaman/komponen/endpoint sama) dan PR/MR terbuka di area yang sama. Dipakai /validate-tiket (PjM di mode tim).
argument-hint: KODE
---
Telusuri ketergantungan tiket `$ARGUMENTS` (baca saja). Baca: `board.md`, `rules.md`.

## Langkah
1. Tiket yang di-link, blocking/blocked, epic dan sprint yang sama (operasi **Baca tiket** dan **Cari tiket**, `board.md`): status, assignee, selesai atau belum.
2. Tiket tak ter-link: operasi **Cari tiket** di project/board yang sama, status Todo/In Progress, kata kunci nama halaman/route, komponen, label, endpoint dari tiket. Baca yang cocok; nilai **selaras** atau **bertabrakan** (AC/aturan yang saling meniadakan) + kutipan.
3. Git/forge: PR/MR terbuka yang menyentuh file/route yang sama (`gh pr list --search`, `gh pr diff --name-only`), worktree batch lain (`git worktree list`), kunci `checkout:*` yang dipegang.
4. Aturan keputusan untuk flow: informasi minim + AC inti jelas → Layak dengan catatan; AC inti kabur → Tidak layak; bertabrakan → Tidak layak sampai diputuskan; tumpang tindih selaras → Layak dengan catatan + saran urutan.

## Keluaran
`${TMPDIR:-/tmp}/validate/<KODE>/<nama agen atau find-related>.md`: tabel ketergantungan (tiket/PR → status → dampak), tabel tak ter-link (tiket → titik tumpang tindih → selaras/bertabrakan + kutipan), risiko bentrok, saran urutan.

## Tidak boleh
Membuat link antar tiket (cukup disarankan), mengomentari/menggeser tiket, mengubah PR/MR, melepas kunci milik orang lain.
