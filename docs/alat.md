# Alat (tools) + MCP

## Skrip `bin/`
| Skrip | Gunanya | Exit penting |
|---|---|---|
| `lock.sh acquire\|release\|who\|move <res> [owner]` | Kunci sumber daya bersama: `port:<n>`, `account:<kunci>`, `checkout:<path>`, `deploy:<env>`. Selalu `AGENT_LOCK_PID=$PPID` | 1 = dipegang agen lain |
| `port-pick.sh <owner> [dari [sampai]]` | Pilih port dev server bebas (default 4100–4199) dan kunci | 1 = tidak ada port bebas |
| `page-shot.mjs --url --out [--viewport] [--targets]` | Screenshot halaman + posisi elemen (`*.boxes.json`) dengan Playwright | 1 = selector tidak ketemu; 3 = Playwright/halaman gagal |
| `annotate.py <in.png> <boxes.json> <out.png>` | Kotak merah + label di screenshot | 1 = masukan salah |
| `compare-shot.py <halaman.png> <prototipe.png> <out.png> [--threshold]` | Bandingkan halaman produk dengan prototipe di state + viewport yang sama; gambar banding + `diff_ratio` | 1 = beda di atas ambang (QA tetap memeriksa) |
| `release-trace.sh <primary> <protected> PREFIX...` | Tracing commit rilis → PR → KODE (TSV) | 1 tak terlacak; 3 hotfix belum back-merge |
| `manifest-check.sh <base> <head> KODE...` | Cocokkan KODE di log git dengan daftar tiket | 1 = beda |
| `audit-mode.sh on\|off\|status` | Nyalakan/matikan mode hanya-baca untuk `/audit-issue` | |
| `housekeeping.sh` | Pembersihan berkala (lihat bawah) | |

## Alat uji dan deploy
| Alat | Dipakai untuk |
|---|---|
| Playwright (project, atau global untuk `page-shot.mjs`) | Uji alur layar per ukuran layar, regresi `@area-<modul>`, smoke `@smoke-live` |
| axe-core (`@axe-core/playwright` / `@axe-core/cli`) | Aksesibilitas |
| Schemathesis, Pact | API dan kontrak (frontend = konsumen Pact) |
| Prism (`@stoplight/prism-cli`) atau MSW project | Mock server dari kontrak (`/mock-api`) |
| `gh` / `glab` | PR/MR, status check, deploy pratinjau otomatis |
| CLI hosting (`vercel`, `netlify`, `wrangler`, `firebase`) | Deploy pratinjau/staging/production, sesuai memory project |
| Browser tertanam Orca | Lihat halaman bersama user (bukan bukti uji) |
| graphify | Peta codebase; `graphify update` setelah sinkron dokumen |

## MCP
| MCP / connector | Dipakai untuk |
|---|---|
| Platform tiket (sesuai memory project) | GitHub/GitLab lewat `gh`/`glab` (atau MCP GitHub/GitLab); Jira lewat connector Atlassian (nama tool berbeda per mesin, mis. `mcp__claude_ai_Atlassian__*`); Linear lewat connector Linear. Operasi lengkap: `skills/_shared/board.md` |
| Claude Docs | Hanya bila platform dokumentasi = `claude-docs` |
| Figma (bila tersedia) | Membaca desain lama untuk project yang belum memakai prototipe workflow UI/UX |

## Pembersihan otomatis
`bin/housekeeping.sh` jalan tiap jam (macOS: launchd `launchd/com.frontendworkflow.housekeeping.plist`; Linux: baris crontab yang dicetak `install.sh`). Hanya menyentuh folder di `~/.agent-workflow/build-roots.txt` (di bawah `$HOME`) dan `/tmp/qa`. Dilewati saat ada deploy/build/e2e berjalan.

| Yang dibersihkan | Harian (03:00) | Mingguan (Minggu 03:30) |
|---|---|---|
| `playwright-report/`, `test-results/` | > 7 hari | > 7 hari |
| Isi `/tmp/qa` | > 7 hari | > 7 hari |
| Cache build (`.next/cache`, `.turbo`, `.vite`, `.parcel-cache`, `node_modules/.cache`) | — | > 7 hari |
| `node_modules` worktree tiket `<repo>-<nomor>` | — | tidak disentuh > 14 hari |
| Cache npm / pnpm / yarn | — | Ya |

Darurat: disk kosong < 20 GB → pembersihan harian + ringan, notifikasi sekali sehari bila masih penuh. Log: `~/.agent-workflow/logs/housekeeping-frontend.log`.

---
[← kembali ke README](../README.md)
