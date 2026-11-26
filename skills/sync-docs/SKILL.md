---
name: sync-docs
description: Skill internal workflow Frontend. Mengambil versi terbaru dokumen project (business discovery, repo desain/prototipe, kontrak API, blueprint) dari lokasi di memory project, lalu graphify update bila dipakai; mencatat ref yang dibaca. Dipakai /validate-tiket, /develop-tiket, /rilis-tiket.
argument-hint: "[KODE]"
---
Sinkronkan sumber dokumen sekali per sesi. Aturan: `rules.md` (Lokasi, Isi memory project).

## Langkah
1. Baca memory project: **Sumber dokumen** (business discovery, kontrak API OpenAPI + Pact, blueprint), **Repo desain** (`design-input.md`) dan **Branch project**. Belum ada → cari dulu di repo (`docs/`, `openapi*.{yml,yaml,json}`, `pacts/`, link Figma di README), lalu tanya user sekali (path + fungsinya), simpan di memory project (`rules.md` → Lokasi).
2. Sumber di repo yang sama dengan kode → `git fetch upstream`, baca dari `upstream/<protected>` dengan `git show upstream/<protected>:<path>` tanpa checkout.
3. Repo dokumen terpisah → `git -C <checkout dokumen> pull --ff-only` (bukan worktree primary repo kode); gagal fast-forward → berhenti dan tanya.
4. **Repo desain:** `git -C <checkout repo desain> pull --ff-only` (belum ada checkout → clone sejajar repo kode setelah bertanya); catat hash. Untuk KODE: alamat `prototypes/<KODE>/` terbuka (HTTP 200) dan daftar layar + state dari `index.html`; halaman handover ada; `build/css/tokens.css` ada. Belum terbit → cek `preview/<KODE>/` dan catat. Project tanpa repo desain: link Figma/gambar di tiket, catat waktu ubah terakhir bila bisa.
5. Project memakai graphify (`graphify-out/` ada) → `graphify update`.

## Keluaran
Tabel `Dokumen | Lokasi | Ref/hash/waktu | Status (terbaca/tidak ada/gagal)`. Tabel ini masuk laporan validasi, Acuan tiket, dan rencana.

## Tidak boleh
Checkout atau mengubah file di repo kode; menulis ke repo dokumen.
