---
name: read-ticket
description: Skill internal workflow Frontend. Mengambil tiket, komentar, lampiran, dan link dari platform tiket, lalu merangkum AC, jenis tiket, halaman yang disentuh, dan jejak pengerjaan sebelumnya. Dipakai /validate-tiket dan /develop-tiket.
argument-hint: KODE
---
Baca tiket `$ARGUMENTS` (baca saja). Aturan: `rules.md`, `credentials.md`.

## Langkah
1. `getJiraIssue` (dengan komentar) dan tiket yang di-link (`searchJiraIssuesUsingJql` bila perlu).
2. Catat: judul, jenis (bug / fitur / hotfix / chore), **AC bernomor** (AC tidak bernomor → beri nomor sendiri, sebut di keluaran), halaman/route dan komponen yang disebut, browser/ukuran layar yang disebut, env/URL/versi yang disebut, reporter + sapaan yang dipakai tim.
3. Lampiran: gambar/mockup/video/HAR diunduh ke `${TMPDIR:-/tmp}/<flow>/<KODE>/lampiran/` dan dibaca; gagal dibuka → catat.
4. **Deteksi jejak** pengerjaan sebelumnya:
   - Branch: `git branch -r --list 'origin/*/<KODE>*' | grep -E '/<KODE>(-r[0-9]+)?$' | grep -vE 'origin/(un)?revert/'`.
   - PR/MR: `gh pr list --repo <upstream> --state all --search <KODE>` / `glab mr list --all --search <KODE>`.
   - Komentar tiket berisi laporan uji/rencana agen.
   Ada → kumpulkan penolakan sejak putaran terakhir: komentar manusia di tiket (arahan QA) + komentar review manusia di PR/MR. PR/MR sudah merged → catat "jejak merged" (putaran baru memakai branch `<jenis>/<KODE>-r<n>`).
   Jejak ada tapi tidak ada komentar penolakan → catat "penolakan tidak diketahui" (flow akan bertanya).

## Keluaran
Blok ringkas: KODE, jenis, AC bernomor, halaman/komponen, browser/ukuran, env/versi, lampiran (terbaca/gagal), jejak (tidak ada / ada + daftar penolakan dengan sumber / merged).

## Tidak boleh
Menulis, mengomentari, atau menggeser tiket; menyalin kredensial dari tiket ke keluaran.
