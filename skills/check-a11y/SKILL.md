---
name: check-a11y
description: Skill internal workflow Frontend. Memeriksa aksesibilitas halaman/state yang disentuh tiket dengan axe-core (desktop dan ponsel) plus cek keyboard singkat, dengan gerbang - pelanggaran critical/serious baru di area tiket = gagal. Khas web. Dipakai /develop-tiket langkah 5 (QA).
argument-hint: "KODE <url...>"
---
Cek aksesibilitas `$ARGUMENTS`. Baca: `browser.md` (Aksesibilitas).

## Langkah
1. Daftar halaman + state dari TC UI di rencana (termasuk dialog/menu terbuka, state error form).
2. axe di tiap halaman/state, desktop dan ponsel: `@axe-core/playwright` di spec (`new AxeBuilder({ page }).withTags(['wcag2a','wcag2aa','wcag21aa']).analyze()`), atau `npx @axe-core/cli <url> --tags wcag2a,wcag2aa` bila project belum punya. Simpan JSON hasil di `${TMPDIR:-/tmp}/qa/<KODE>/a11y-<halaman>-<ukuran>.json`.
3. **Baru vs lama:** bandingkan dengan hasil yang sama di `<base>` (server dari worktree base, atau staging) bila memungkinkan; elemen pelanggaran yang berada di komponen yang diubah diff = **baru**.
4. **Gerbang:** pelanggaran `critical`/`serious` baru → TC a11y **Gagal**. Lama → temuan, tidak memblokir.
5. **Keyboard singkat** (Playwright `keyboard.press('Tab')`): urutan fokus logis, fokus terlihat (screenshot bertanda), dialog menjebak fokus dan tertutup dengan Esc, tombol bisa diaktifkan dengan Enter/Space.

## Keluaran
Tabel `Halaman/state | ukuran | critical | serious | moderate | minor | baru?` + daftar pelanggaran baru (aturan, elemen, saran) untuk `report.md`.

## Tidak boleh
Mengubah kode; menganggap lulus bila axe gagal dijalankan (tulis **Tertahan** + alasan).
