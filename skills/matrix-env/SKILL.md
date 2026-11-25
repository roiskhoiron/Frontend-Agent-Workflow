---
name: matrix-env
description: Skill internal workflow Frontend. Menyusun Matriks env - status tiap endpoint tiket di server dev, staging, dan production (Sesuai kontrak / Beda kontrak / Belum ada / Tidak dicek), method aman saja di staging/production. Dipakai /develop-tiket, /rilis-tiket, /branch-manager.
argument-hint: "KODE... [--server dev,staging,production]"
---
Matriks env untuk `$ARGUMENTS`. Baca: `rules.md` (Isi memory project: Env dan server API), `credentials.md`.

## Langkah
1. **Server:** base URL API dev/staging/production + nama variabel env API project dari memory. Belum ada → cari di `.env.example`, konfigurasi hosting, kode klien; tanya sekali, simpan (tanpa kredensial).
2. **Endpoint:** dari kontrak di Acuan tiket (atau diff kode untuk rilis: `git diff <base>...<head>` di API client).
3. Per server:
   | Server | Cara cek |
   |---|---|
   | dev | Schemathesis endpoint tiket + verifikasi Pact |
   | staging, production | Method aman (GET/HEAD/OPTIONS) + interaksi Pact aman; **tanpa fuzzing, tanpa menulis data**. Endpoint tulis → cek dari spec yang disajikan server (mis. `/openapi.json`) atau respons method aman; tidak bisa → **Tidak dicek** + alasan |
4. CORS: untuk server yang dipanggil langsung dari browser, cek preflight `OPTIONS` dengan `Origin` situs env itu; ditolak → **Beda kontrak** (catatan CORS).

## Keluaran
Tabel `Endpoint | dev | staging | production | catatan`, ditulis ke `${TMPDIR:-/tmp}/qa/<KODE>/matriks-env.md`. Beda dengan kontrak di Acuan → tandai **perlu keputusan** (flow bertanya sebelum rencana/deploy).

## Tidak boleh
Fuzzing/menulis data ke staging/production; kredensial di file.
