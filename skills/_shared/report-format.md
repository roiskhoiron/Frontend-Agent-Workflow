# Format laporan dan platform dokumentasi

Laporan ditulis oleh agen management (Validator/SPV/Release) lewat skill `/write-report`. QA, Auditor, dan tim validasi tidak menulis ke platform: mereka menulis Markdown + screenshot di `${TMPDIR:-/tmp}/...` lalu menyerahkan path-nya ke SPV.

Gaya: Bahasa Indonesia, singkat padat, ramah pemula. Tabel dan diagram mermaid lebih dulu daripada paragraf. Tanpa kredensial (sebut nama kunci saja, mis. `QA_USER1`).

## Platform dokumentasi
Dicatat sekali di memory project oleh `/setup-docs`.

| Platform | Tempat | Link di komentar tiket |
|---|---|---|
| `repo-markdown` (default) | worktree dokumen `<repo>-docs` sejajar checkout, branch `agent-docs` (nama dari memory project) di `origin`, folder `docs/` | URL file di forge (`https://<host>/<fork>/blob/agent-docs/docs/...`) |
| `claude-docs` | Claude Docs (connector `Claude Docs`, `batch`/`update`) | link dokumen |
| lainnya (Confluence, Notion, ...) | sesuai memory project | link halaman |

**`repo-markdown`, cara kerja:**
- Worktree dokumen dibuat sekali: `git -C <checkout> worktree add ../<repo>-docs -b agent-docs upstream/<protected>` (branch sudah ada di `origin` → `git -C <checkout> worktree add ../<repo>-docs agent-docs` setelah `git fetch origin`). Tidak pernah dihapus agen.
- Sebelum menulis: kunci `checkout:<path worktree dokumen>`, `git pull --ff-only origin agent-docs`.
- Tulis file, salin screenshot ke folder `img/` di sebelahnya, `git add` path itu saja, commit `docs: <KODE> <jenis laporan>`, `git push origin agent-docs`, lepas kunci.
- Branch `agent-docs` hanya berisi `docs/`; tidak pernah dijadikan PR ke upstream kecuali user memintanya.

| Dokumen | Lokasi default |
|---|---|
| Laporan validasi | `docs/tickets/<KODE>/validasi.md` |
| Rencana dan test case | `docs/tickets/<KODE>/rencana.md` (`--batch`: `docs/tickets/batch-<KODE pertama>/rencana.md`) |
| Laporan uji dan screenshot | `docs/tickets/<KODE>/uji.md` dan `docs/tickets/<KODE>/img/` |
| Laporan audit | `docs/audit/<slug>.md` dan `docs/audit/<slug>/img/` |
| Perubahan rilis | `docs/rilis/vX.Y.Z.md` |

Validasi ulang / revisi menambah file baru dengan akhiran putaran (`validasi-r2.md`), bukan menimpa yang lama. Mermaid ditulis sebagai blok ```` ```mermaid ```` (dirender GitHub/GitLab).

## Laporan validasi (`/validate-tiket`)
1. **Judul**: `Validasi PROJ-1234 — judul singkat`, tanggal, nama user.
2. **Ringkasan**: tabel AC → status.
   | AC | Isi singkat | Status |
   |---|---|---|
   | AC1 | Tombol Simpan aktif setelah form lengkap | Lulus |
3. **Keputusan**: satu kalimat tebal — **Layak**, **Layak dengan catatan**, atau **Tidak layak** — lalu diagram mermaid dan alasan singkat.
4. **Satu bagian per TC** (`TC1 — judul`): kalimat pertama **Lulus**/**Tertahan** + alasan; langkah bernomor; screenshot bertanda per ukuran layar.
5. **Temuan**: data uji (awalan KODE), akun (nama kunci), ref/commit/URL yang diuji, browser + ukuran layar, ref dokumen hasil `/sync-docs`, checklist tindak lanjut (`- [ ] ...`).

**Mode tim**: setelah Keputusan, tambah bagian **Bisnis** (PdM), **Desain** (Product Designer; link mockup wajib), **Teknis** (HoE + Contract Runner + Spesialis eskalasi), **Ketergantungan** (PjM), masing-masing menyebut agen sumber `<Nama> (<Label>)` dan tingkat keyakinan.
**Validasi ulang**: laporan berbentuk delta (link laporan lama) + bagian **Yang ditolak** (poin, sumber komentar, golongan, saran tugas/TC).

## Rencana (`/write-plan`)
Judul `Rencana <KODE> — <judul singkat>`; bagian: Tujuan dan AC, Acuan tiket, Worktree + branch + base hash, Pendekatan, Yang ditolak (bila ada), Tugas bernomor (batas file per Coder), Matriks env, Test case (ID TC, AC, server, ukuran layar, alat, a11y), Risiko untuk Reviewer, Di luar scope, Pertanyaan terbuka.

## Laporan uji (`/develop-tiket`)
1. **Judul**: `Uji PROJ-1234 — judul singkat`, tanggal, nama user.
2. **Ringkasan**: tabel TC → AC → Lulus/Gagal/Tertahan, jenis uji (Playwright / axe / Schemathesis / Pact).
3. **Keputusan**: **Siap review** atau **Belum siap** + alasan.
4. **Satu bagian per TC**: hasil di kalimat pertama, langkah bernomor, screenshot bertanda per ukuran layar; API/kontrak → tabel endpoint → hasil.
5. **Responsif**: tabel TC × ukuran layar (desktop/tablet/ponsel) × browser.
6. **Aksesibilitas**: tabel halaman/state → jumlah pelanggaran per tingkat → yang baru dari tiket ini.
7. **Server**: tabel deploy → env + base URL API + hash; tabel TC × server (dev/staging/production); endpoint yang sudah/belum ada per server (Matriks env).
8. **Regresi area terdampak**: modul → spec `@area-<modul>` → hasil; spec baru yang ditambahkan ke suite.
9. **UI vs mockup**: tabel layar/state/ukuran → sesuai/beda, screenshot bertanda di samping acuan mockup.
10. **Temuan**: branch + commit, URL pratinjau, data uji, checklist tindak lanjut.

## Laporan audit (`/audit-issue`)
Satu dokumen per audit (dibuat di awal dengan bagian kosong "belum diisi", lalu diisi; dokumen yang sama).
1. **Ringkasan untuk awam** (3–5 kalimat). 2. **Permintaan asli** + daftar lampiran (terbaca / gagal + alasan). 3. **Temuan per pertanyaan** dengan bukti (file:baris di ref, commit, log, screenshot bertanda). 4. **Lampiran vs kode vs halaman** (`Lampiran | Kode | Halaman | Beda?`). 5. **Akar masalah** + keyakinan (**pasti** / **kuat** / **dugaan**), dampak, ukuran perbaikan. 6. **Saran langkah berikutnya**. 7. **Saran tiket** (tidak dibuat). 8. **Cara audit**: ref, URL, browser, alat, yang tidak bisa diperiksa.

`repo-markdown` + mode audit: selama mode audit, laporan ditulis di `${TMPDIR:-/tmp}/audit/<slug>/laporan.md`; setelah `audit-mode.sh off`, SPV menyalinnya ke worktree dokumen dan push (satu-satunya tulisan, sesudah audit selesai).

## Laporan rilis (`/branch-manager`)
Judul `Perubahan rilis vX.Y.Z`: (1) mermaid branch tiket → `<protected>` → `<primary>` → tag → production; (2) versi + hash `<primary>`, `<protected>`, `<sha-rilis>`; (3) tabel `KODE | Ringkasan | Branch | PR/MR | Programmer | Status Jira`; (4) commit tak terlacak dan tiket belum Done; (5) Matriks env production; (6) regresi penuh di staging (URL + hash + env API): spec → hasil → tiket terkait; (7) rekomendasi agen; (8) deploy production (URL + hash), smoke live, PR rilis, tag.

## Komentar tiket
Ditulis seperti rekan satu tim yang sopan, bisa dipahami PM/QA/bisnis.
- Orang pertama **aku**, hangat dan to the point; paling banyak satu emoji.
- **Bahasa awam:** jelaskan dampak bagi pengguna, hindari istilah teknis (endpoint, 404, AC, TC, viewport, merge, deploy); kalau terpaksa, beri arti singkat dalam kurung.
- **Sapaan**: pakai sapaan yang sudah dipakai tim untuk orang itu di komentar tiket; belum ada → **Kak <nama depan>**. Jangan menebak mas/mba dari nama.
- Baris pertama **selalu** memuat link laporan, dibungkus kalimat sapaan.
- Isi: apa yang aku cek, hasilnya, apa yang perlu dari mereka. Kabar kurang enak disampaikan jujur tapi lembut, dengan jalan keluar.

**Contoh — validasi layak dengan catatan**
```
Halo Kak Rina, aku sudah cek tiket ini ya. Laporan lengkapnya di sini: <link laporan>
Tiket ini bisa mulai dikerjakan. Ada satu hal yang belum bisa aku coba, yaitu tampilan di HP, karena desain untuk layar kecil belum ada.
Tiketnya aku pindah ke In Progress. Kalau desain layar HP sudah siap, kabari aku ya, nanti langsung aku lengkapi. Terima kasih 🙏
```

**Contoh — Ready To Review**
```
Halo Kak Sari, perubahan di tiket ini sudah siap dicek. Laporan ujinya ada di sini: <link laporan>
Semua yang diminta sudah aku coba di laptop, tablet, dan HP, hasilnya sesuai.
Halaman pratinjau: <URL pratinjau> · Perubahan kode: <link PR>
Kalau ada yang kurang pas, tinggal kabari aku. Terima kasih sudah meluangkan waktu!
```
