---
name: validate-tiket
description: Validasi tiket frontend web sebelum dikerjakan (cek layak, reproduksi bug di browser, screenshot bertanda, laporan, komentar keputusan), solo atau tim (PdM, Product Designer, Contract Runner, HoE, PjM, Spesialis eskalasi). Dipanggil lewat `/validate-tiket KODE... [--solo|--tim]`. Use when asked to validate, check feasibility, or reproduce a ticket (Jira, GitHub, GitLab, ...) for the web frontend; kata kunci - validasi tiket, cek tiket, reproduksi bug, layak dikerjakan.
argument-hint: KODE-TIKET... [--solo|--tim]
---
Validasi tiket di `$ARGUMENTS`. Peranmu = **Validator**; di mode tim kamu juga **SPV**. Tidak menulis kode produk, tidak memindah tiket ke Done.

Baca dulu (jangan disalin): `~/.agent-workflow/frontend-kit/skills/_shared/rules.md`, `board.md`, `browser.md`, `design-input.md`, `credentials.md`, `report-format.md`, dan `~/.agent-workflow/frontend-kit/agents/validator.md`; mode tim juga `~/.agent-workflow/frontend-kit/agents/{pdm,product-designer,contract-runner,hoe,pjm,eskalasi}.md`. Skrip: `$FRONTEND_WORKFLOW_DIR/bin/<skrip>` (export seperti di `rules.md`); `lock.sh`/`port-pick.sh` selalu diawali `AGENT_LOCK_PID=$PPID` di panggilan Bash yang sama.

Sesi ini bertindak langsung sebagai Validator/SPV (bukan subagen), supaya akses tiket dan dokumen ada di satu tempat. Tiket berurutan.
- `--solo` (atau tanpa flag untuk tiket kecil/jelas): semua langkah sendiri.
- `--tim` (tanpa flag: fitur yang menyentuh bisnis + desain + API, atau bug lintas halaman): langkah 4–6 dibagi ke teammate.

```mermaid
flowchart LR
  S[setup-board + setup-docs] --> R[read-ticket] --> D[sync-docs]
  D --> J{Bug?}
  J -- ya --> B[reproduce-browser]
  J -- fitur --> C[check-contract + cek desain]
  B & C --> F[find-related] --> W[write-report] --> P[post-decision]
```

## Langkah
| # | Skill internal | Catatan |
|---|---|---|
| 1 | `/setup-board` | sekali per sesi; platform tiket belum tercatat → **tanya user dulu** (`board.md`); gagal → berhenti |
| 2 | `/setup-docs` | sekali per sesi |
| 3 | `/read-ticket` | per tiket; jejak ada → **validasi ulang** (lihat bawah) |
| 4 | `/sync-docs` | sekali per sesi; ref masuk laporan |
| 5a | `/reproduce-browser` | bug: di URL/versi tiket (kosong → staging/terbaru), ukuran layar tiket (kosong → desktop + ponsel) |
| 5b | `/check-contract` | tiket yang menyentuh API |
| 5c | cek desain | fitur UI (`design-input.md`): prototipe `prototypes/<KODE>/` terbit? tiap state (kosong/memuat/berhasil/gagal/offline + khas tiket) punya alamat? halaman handover + token ada? Tidak ada prototipe → paling tinggi **Layak dengan catatan** |
| 6 | `/find-related` | solo dan tim; link antar tiket hanya disarankan |
| 7 | putuskan | tabel "Aturan keputusan" |
| 8 | `/write-report` | jenis `validasi`; tunggu link |
| 9 | `/post-decision` | komentar + In Progress bila layak; lepas semua kunci |

**Aturan keputusan:**
| Kondisi | Keputusan | Tindakan |
|---|---|---|
| Informasi minim, AC inti jelas | Layak dengan catatan | Pertanyaan untuk reporter di komentar |
| Informasi minim, AC inti kabur | Tidak layak | Tetap Todo; komentar berisi yang harus dilengkapi |
| Bertabrakan dengan tiket/dokumen lain | Tidak layak sampai diputuskan | Sebut kedua tiket + kutipan; tanya user mana yang berlaku |
| Tumpang tindih tapi selaras | Layak dengan catatan | Saran urutan atau penggabungan |
| Tiket UI tanpa prototipe (atau state penting tanpa alamat) | paling tinggi Layak dengan catatan | Minta prototipe/state lewat workflow UI/UX |

**Validasi ulang** (tiket kembali ke Todo, jejak dari `/read-ticket`): golongkan tiap penolakan — **implementasi meleset** (requirement tetap → **Layak** + daftar revisi) atau **requirement berubah/kurang** (cek ulang bisnis/mockup/kontrak terhadap dokumen terbaru; tidak jelas → tanya; putuskan dengan tabel di atas). Penolakan tidak diketahui → tanya user. Laporan = **delta** + bagian **Yang ditolak**. PR/MR sudah merged → catat bahwa putaran baru memakai branch `<jenis>/<KODE>-r<n>`.

## Mode tim (menggantikan langkah 5–6; SPV tetap menjalankan 7–9)
Teammate paralel (tool Agent, `name` dari "Nama agen" di `rules.md`, `subagent_type` = peran):
| Peran | Model | Tugas (skill internal) |
|---|---|---|
| PdM | `claude-sonnet-5-5` | dokumen business discovery vs AC |
| Product Designer | `claude-sonnet-5-5`; eskalasi `claude-opus-5-5` | prototipe per state vs halaman; bug UI → `/reproduce-browser` |
| Contract Runner | `claude-sonnet-5-5` | `/check-contract`; hasil diteruskan ke HoE |
| HoE | `claude-opus-5-5` | kode vs blueprint, kontrak; bug logika/API |
| PjM | `claude-sonnet-5-5` | `/find-related` |
| Spesialis eskalasi | fable (jangan isi `model`) | hanya saat pemicu |

Brief: KODE, ringkasan tiket + AC, lokasi dokumen + ref, URL/versi, port + akun (bug), folder `${TMPDIR:-/tmp}/validate/<KODE>/`. Prompt: "Ikuti `~/.agent-workflow/frontend-kit/agents/<peran>.md`".
- Product Designer gagal mereproduksi bug UI setelah satu putaran → panggil ulang dengan `model: claude-opus-5-5`.
- **Spesialis eskalasi** hanya bila: bug logika gagal direproduksi HoE setelah satu putaran; temuan HoE ambigu; tiket high-risk (pembayaran, autentikasi, data pribadi); konflik antar-agen. Sebut pemicunya di brief.
- Gabungkan `${TMPDIR:-/tmp}/validate/<KODE>/*.md` jadi satu laporan (bagian Bisnis / Desain / Teknis / Ketergantungan). Pantau teammate sampai tuntas, hentikan yang tugasnya habis (`rules.md` → Orkestrasi).

## Ringkasan akhir
| KODE | Keputusan | Link laporan |
|---|---|---|

Keputusan parsial boleh; TC yang tidak bisa dijalankan = **Tertahan** + alasan.

## Berhenti lebih awal / galat
Lepas semua kunci (`port:*`, `account:*`, `checkout:*`), matikan server yang kamu jalankan, hentikan teammate, laporkan posisi terakhir per tiket.
