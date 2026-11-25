---
name: sync-docs
description: Skill internal workflow Frontend. Mengambil versi terbaru dokumen project (business discovery, mockup/Figma, kontrak API, blueprint) dari lokasi di memory project, lalu graphify update bila dipakai; mencatat ref yang dibaca. Dipakai /validate-tiket, /develop-tiket, /rilis-tiket.
argument-hint: "[KODE]"
---
Sinkronkan sumber dokumen sekali per sesi. Aturan: `rules.md` (Lokasi, Isi memory project).

## Langkah
1. Baca memory project: **Sumber dokumen** (business discovery, desain/mockup, kontrak API OpenAPI + Pact, blueprint) dan **Branch project**. Belum ada → cari dulu di repo (`docs/`, `openapi*.{yml,yaml,json}`, `pacts/`, link Figma di README), lalu tanya user sekali (path + fungsinya), simpan di memory project (`rules.md` → Lokasi).
2. Sumber di repo yang sama dengan kode → `git fetch upstream`, baca dari `upstream/<protected>` dengan `git show upstream/<protected>:<path>` tanpa checkout.
3. Repo dokumen terpisah → `git -C <checkout dokumen> pull --ff-only` (bukan worktree primary repo kode); gagal fast-forward → berhenti dan tanya.
4. Figma/desain online: catat link frame dan waktu ubah terakhir bila alatnya tersedia; tidak bisa dibuka → catat "tidak bisa dibuka" + alasan.
5. Project memakai graphify (`graphify-out/` ada) → `graphify update`.

## Keluaran
Tabel `Dokumen | Lokasi | Ref/hash/waktu | Status (terbaca/tidak ada/gagal)`. Tabel ini masuk laporan validasi, Acuan tiket, dan rencana.

## Tidak boleh
Checkout atau mengubah file di repo kode; menulis ke repo dokumen.
