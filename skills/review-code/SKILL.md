---
name: review-code
description: Skill internal workflow Frontend. Review diff branch tiket di sesi terpisah dari Coder - prioritas performa ringan + keamanan sisi klien, lalu logika vs aturan bisnis/AC dan kontrak; review ditulis di PR/MR. Dipakai /develop-tiket langkah 4 (Reviewer).
argument-hint: "KODE <worktree> <nomor PR/MR>"
---
Review `$ARGUMENTS`. Baca: `rules.md`; Acuan tiket + rencana (bagian Risiko untuk Reviewer).

## Langkah
1. `git -C <worktree> diff <base>...HEAD` + kode yang terhubung (pemanggil, hook, store, route, server component/loader).
2. **Prioritas 1 — keamanan sisi klien:** XSS (`dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `{@html}`, URL `javascript:`), sanitasi input dan respons, open redirect, rahasia/kunci API di bundle (variabel `NEXT_PUBLIC_`/`VITE_` berisi rahasia), token di `localStorage`, otorisasi hanya di sisi klien, data sensitif di log/console/URL, `target=_blank` tanpa `rel`, skrip pihak ketiga baru, CSP dilemahkan.
3. **Prioritas 1 — performa ringan:** render berulang (dependency effect salah, objek/fungsi baru di prop), fetch berulang/waterfall, ukuran bundle (import pustaka penuh, dependensi baru), gambar tanpa ukuran (layout shift), daftar panjang tanpa virtualisasi bila perlu, animasi yang memicu layout (bukan `transform`/`opacity`), memory leak (listener/timer/subscription tanpa cleanup), hidrasi tidak cocok (SSR).
4. **Aksesibilitas & responsif** di diff: semantik, label, fokus, kontras token, `prefers-reduced-motion`, breakpoint sesuai mockup.
5. **Prioritas 2 — logika vs requirement:** alur memenuhi tiap AC dan aturan bisnis di Acuan; kontrak dipakai sesuai Matriks env (field, kode galat, state error di UI); tes ada untuk logika berisiko.
6. Tabel temuan: `file:baris | masalah | saran | tingkat (wajib/saran) | kategori (keamanan/performa/a11y/logika)`. Tulis di PR/MR, satu komentar per putaran: `gh pr review <n> --comment --body-file <file>` / `glab mr note <n> --message "..."`.

## Keluaran (ke SPV)
**Bersih** (siap QA) atau **Revisi** + jumlah temuan wajib + link komentar review.

## Tidak boleh
Review kode yang kamu tulis/ubah; mengubah kode produk; approve/merge PR.
