# Masalah umum

| Gejala | Artinya / yang dilakukan |
| --- | --- |
| "DIBLOKIR oleh guard: ..." | Perintah melanggar pagar. Baca pesannya; biasanya menyebut cara yang benar |
| `install.sh`: "Tidak dipasang: nama skill/agen ini sudah dipakai kit lain" | Kit Mobile (atau lainnya) sudah memasang perintah/agen dengan nama sama. Pilih satu kit per mesin, atau `./install.sh --force` |
| "Teammate mode mati" | Buka ulang Claude dengan `claude --teammate-mode auto`, lalu ulangi perintah |
| "Jalankan dari workspace domain" | `/develop-tiket` dijalankan dari root project. Buka workspace domain di Orca |
| "belum punya daftar transisi" | Project baru: agen menunjukkan daftar status, kamu pilih id Todo, In Progress, Ready To Review |
| `port-pick.sh` exit 1 | Semua port 4100–4199 terpakai/terkunci. Matikan dev server lama, atau kunci yang pemiliknya sudah mati akan diambil ulang otomatis |
| `page-shot.mjs` exit 3 | Playwright tidak ditemukan atau halaman gagal dibuka. Pasang Playwright global, cek server/URL |
| `page-shot.mjs` exit 1 | Selector tidak ditemukan; dicatat di laporan, tidak ditebak |
| Link laporan tidak bisa dibuka | `repo-markdown`: branch `agent-docs` belum di-push atau fork privat; cek `git -C ../<repo>-docs log origin/agent-docs` |
| Deploy pratinjau tidak muncul | Hosting otomatis per PR belum aktif, atau CLI hosting belum login. Agen bertanya; token tidak pernah ditulis ke file |
| TC **Tertahan** | Tidak bisa diuji (endpoint belum ada, mockup tidak ada, akun tidak ada); alasannya tertulis di laporan |

---
[← kembali ke README](../README.md)
