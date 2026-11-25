---
name: write-release-notes
description: Skill internal workflow Frontend. Menyusun Markdown dokumen "Perubahan rilis vX.Y.Z" dari hasil tracing, Matriks env production, regresi staging, dan rekomendasi agen, untuk diterbitkan. Dipakai /branch-manager.
argument-hint: "<vX.Y.Z>"
---
Susun dokumen rilis `$ARGUMENTS`. Baca: `report-format.md` (Laporan rilis).

## Langkah
1. Bahan: `${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/trace.md`, `regresi.md`, Matriks env production, PR rilis (bila sudah ada), deploy production + smoke live (bila sudah ada).
2. Tulis `${TMPDIR:-/tmp}/rilis/<vX.Y.Z>/rilis.md` dengan urutan bagian di `report-format.md` → Laporan rilis.
3. **Rekomendasi agen** dari temuan: tiket belum Done → minta pemiliknya memindah ke Done atau keluarkan; commit tak terlacak → tanya asalnya; endpoint production **Belum ada**/**Beda kontrak** → tunda atau keluarkan tiket; spec regresi gagal → keluarkan tiket terkait atau tunda; suite kosong → risiko.
4. Pembaruan (setelah deploy/tag): perbarui file yang sama, bagian 8.

## Keluaran
Path `rilis.md` + daftar rekomendasi (bernomor, tiap butir: siapa yang mengerjakan — agen atau manusia).

## Tidak boleh
Menerbitkan sendiri (flow yang menerbitkan); kredensial.
