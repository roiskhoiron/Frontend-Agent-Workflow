---
name: write-report
description: Skill internal workflow Frontend. Menerbitkan laporan (validasi, rencana, uji, audit, rilis) dari file Markdown + screenshot lokal ke platform dokumentasi di memory project (default Markdown di worktree <repo>-docs, atau Claude Docs), lalu mengembalikan link-nya. Dipakai semua flow.
argument-hint: "<jenis: validasi|rencana|uji|audit|rilis> <KODE|slug|vX.Y.Z> <file.md> [folder screenshot]"
---
Terbitkan laporan `$ARGUMENTS`. Baca: `report-format.md` (format per jenis dan Platform dokumentasi), `rules.md`.

## Langkah
1. Periksa isi file terhadap format jenisnya di `report-format.md`; bagian wajib kosong → lengkapi dari bahan yang ada atau tulis "tidak ada" + alasan. Cari kredensial yang bocor (nilai dari `.env*`, pola token) → hapus, sebut nama kuncinya saja.
2. Platform dari memory project (belum ada → berhenti: platform dokumentasi belum disiapkan).
3. **`repo-markdown`:**
   - `AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/lock.sh" acquire checkout:<path worktree dokumen> <owner>`; `git -C <worktree dokumen> pull --ff-only origin agent-docs`.
   - Salin ke lokasi default (`report-format.md`); sudah ada untuk putaran sebelumnya → akhiran `-r<n>`, jangan menimpa. Screenshot ke `img/` di sebelahnya; link gambar relatif.
   - `git -C <worktree dokumen> add <path itu saja>`, `commit -m "docs: <KODE> <jenis>"`, `push origin agent-docs`, lepas kunci.
   - Link = pola URL forge + path file.
4. **`claude-docs`:** buat dokumen (judul sesuai `report-format.md`) dengan connector Claude Docs, unggah screenshot, isi bagian. Revisi rencana/laporan yang sama → perbarui dokumen yang ada.
5. Platform lain → alat dari memory project.
6. **Tunggu link kembali** dan buka sekali untuk memastikan bisa diakses. Tanpa link → gagal (flow tidak boleh lanjut ke komentar tiket).

## Keluaran
Link laporan + path/ID dokumen.

## Tidak boleh
Menulis kredensial; menulis ke branch selain `agent-docs`; force-push; menimpa laporan putaran lama.
