---
name: check-contract
description: Skill internal workflow Frontend. Menjalankan Schemathesis dan Pact untuk endpoint yang disentuh tiket, dan membandingkan spec API dengan pemakaian di kode klien (API client, tipe). Dipakai /validate-tiket (Contract Runner).
argument-hint: KODE
---
Cek kontrak API untuk tiket `$ARGUMENTS`. Baca: `rules.md`, `credentials.md`.

## Langkah
1. Daftar endpoint yang disentuh tiket (dari tiket, mockup, dan kode klien: `git grep` path di ref `upstream/<protected>`).
2. Lokasi spec OpenAPI dan kontrak Pact dari memory project (hasil sinkron dokumen). Tidak ada → "tidak ada", lewati 3–4 untuk endpoint itu.
3. **Schemathesis** hanya endpoint tiket: dev penuh (`schemathesis run <spec> --url <dev> --include-path <path>`); staging/production hanya method aman (GET/HEAD/OPTIONS), tanpa fuzzing, tanpa menulis data. **Pact:** frontend = konsumen; verifikasi kontrak yang ada terhadap provider dev bila ada broker/berkas pact, interaksi aman saja untuk staging/production.
4. **Diff spec vs kode klien** di ref: path, method, field request/response, tipe (TypeScript), wajib/opsional, kode galat yang ditangani UI.
5. Hasil per endpoint × server: **Sesuai kontrak** / **Beda kontrak** / **Belum ada** / **Tidak dicek** (+ alasan).

## Keluaran
`${TMPDIR:-/tmp}/validate/<KODE>/<nama agen>.md`: perintah yang dijalankan, tabel endpoint × server, tabel diff, potongan output penting (output mentah di file terpisah di folder yang sama).

## Tidak boleh
Fuzzing atau menulis data ke staging/production; mengubah spec/kontrak/repo; kredensial di file temuan; menyimpulkan layak/tidak.
