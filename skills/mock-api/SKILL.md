---
name: mock-api
description: Skill internal workflow Frontend. Menjalankan mock server API dari kontrak (OpenAPI/Prism atau MSW milik project) di port terkunci, supaya frontend bisa dikerjakan dan diuji sebelum endpoint tersedia di server dev. Khas web. Dipakai /develop-tiket (Coder, QA).
argument-hint: "KODE <start|stop> [spec]"
---
Mock API untuk `$ARGUMENTS`. Baca: `browser.md` (Port dev server), `rules.md`.

## Kapan
Endpoint tiket **Belum ada** atau **Beda kontrak** di dev (Matriks env), dan rencana menyetujui kerja terhadap mock. Hasil uji terhadap mock **bukan** bukti di server: TC server itu tetap **Tertahan** dengan alasan "endpoint belum ada; diuji terhadap mock kontrak".

## Langkah (start)
1. Project sudah punya mock (MSW handler, `mocks/`, json-server) → pakai itu, sesuai README project.
2. Belum → mock dari spec OpenAPI di Acuan: `port=$(AGENT_LOCK_PID=$PPID "$FRONTEND_WORKFLOW_DIR/bin/port-pick.sh" <KODE>-mock<n>)`, lalu `npx @stoplight/prism-cli mock <spec> --port $port` di background, log ke `${TMPDIR:-/tmp}/qa/<KODE>/mock-$port.log`. Respons contoh dari spec (`examples`); tidak ada contoh → Prism membangkitkan dari skema.
3. Arahkan aplikasi ke mock lewat variabel env API project saat menjalankan dev server (tidak menulis ke file `.env` yang ter-track).
4. Cek `curl -s -o /dev/null -w '%{http_code}' http://localhost:$port/<path contoh>`.

## Langkah (stop)
Matikan proses mock (pid tercatat), `lock.sh release port:<n> <owner>`.

## Keluaran
`mock=<url> pid=<pid> owner=<owner> spec=<path@ref>`.

## Tidak boleh
Mengubah spec kontrak; menambah dependensi mock ke project tanpa disebut di rencana; menganggap uji mock sebagai Lulus di server.
