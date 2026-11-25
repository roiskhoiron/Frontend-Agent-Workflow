# Platform tiket (papan kerja)

Kit ini **tidak menganggap platform tiket apa pun sebagai default**. Platform dicatat per project di memory project oleh `/setup-board`. Selama belum tercatat, nilainya **none** dan agen wajib bertanya ke user di awal, sebelum membaca atau menulis tiket apa pun.

## Pertanyaan pertama (memory = none)
Kumpulkan fakta dulu (remote `git remote get-url upstream` → GitHub/GitLab; connector yang tersedia di sesi: Atlassian, Linear, GitHub, GitLab; pola KODE yang diketik user), lalu tanya **sekali**:

> Tiket untuk project ini dikelola di mana? Jira · GitHub (Issues / Projects) · GitLab (Issues / Issue Board) · Linear · lainnya (sebutkan)

User belum punya atau bingung → sarankan **satu** alternatif yang paling dekat dengan repo-nya:
| Repo di | Saran | Alasan |
|---|---|---|
| GitHub | **GitHub Projects** (board) + Issues | Satu tempat dengan kode dan PR; cukup `gh` |
| GitLab | **GitLab Issue Board** (label `status::...`) | Satu tempat dengan kode dan MR; cukup `glab` |
| Lainnya | Tanya lagi; jangan memilih sendiri | |

Agen **tidak membuat** board/project baru sendiri; bila user setuju memakai saran itu, berikan langkah singkat untuk membuatnya, lalu tunggu.

Jawaban disimpan sebagai memory project tipe `reference`:
| Kunci | Contoh |
|---|---|
| Platform | `jira` · `github-project` · `github-labels` · `gitlab-board` · `linear` · lainnya |
| Lokasi | Jira project key `WEB`; GitHub `owner/repo` + nomor project; GitLab `group/project` + nama board |
| Prefix KODE | `WEB` (lihat "KODE tiket") |
| Nama status | kolom/opsi/label untuk **Todo**, **In Progress**, **Ready To Review**, **Done** |
| Alat | connector/CLI yang dipakai (Atlassian MCP, `gh`, `glab`, Linear MCP) |

## KODE tiket
Semua skill memakai **KODE = `<PREFIX>-<nomor>`** (dipakai di nama branch, worktree `<repo>-<nomor>`, commit, dan `release-trace.sh`).
- Jira / Linear: kunci issue apa adanya (`WEB-123`).
- GitHub / GitLab Issues: prefix dari memory + nomor issue (`#123` → `WEB-123`). User boleh mengetik `#123`, `123`, atau `WEB-123`; agen menormalkannya. Commit dan PR menyebut keduanya: `fix: WEB-123 validasi form (#123)`.
- PR/MR hanya **merujuk** issue (`Refs #123`), **tidak pernah** `Closes/Fixes #123`: menutup issue = Done, dan itu hak manusia.

## Operasi per platform
Skill memakai nama operasi di kolom kiri; caranya dari tabel ini.

| Operasi | Jira (Atlassian MCP) | GitHub | GitLab | Linear / lainnya |
|---|---|---|---|---|
| Cek akses | `atlassianUserInfo` | `gh auth status` | `glab auth status` | tool connector |
| Baca tiket + komentar | `getJiraIssue` | `gh issue view <n> --comments --json ...` | `glab issue view <n> --comments` | tool connector |
| Cari tiket | `searchJiraIssuesUsingJql` (`text ~ "..."`) | `gh issue list --search "..." --state open` | `glab issue list --search "..."` | tool connector |
| Komentar | `addCommentToJiraIssue` | `gh issue comment <n> --body-file <f>` | `glab issue note <n> -m "..."` | tool connector |
| Geser status | `transitionJiraIssue` (id transisi) | Projects: `gh project item-edit --id <item> --project-id <PVT_..> --field-id <field> --single-select-option-id <opsi>`; labels: `gh issue edit <n> --add-label <status> --remove-label <lama>` | `glab issue update <n> --label status::<baru> --unlabel status::<lama>` | tool connector |
| Daftar status | `getTransitionsForJiraIssue` | `gh project field-list <nomor> --owner <owner> --format json` | `glab label list` | tool connector |

Nama tool MCP berbeda per mesin (mis. `mcp__claude_ai_Atlassian__getJiraIssue` atau `mcp__Atlassian__getJiraIssue`); pakai yang tersedia di sesi. Platform tanpa alat di sesi → berhenti dan tanya (sambungkan connector, atau login CLI).

## Setup status papan (sekali per project)
Guard menolak perubahan status sebelum project punya daftar. Jika ditolak "belum punya daftar status":
1. Ambil daftar status dengan operasi **Daftar status**.
2. Tunjukkan tabel `id/opsi/label → nama` ke user.
3. User memilih untuk **Todo**, **In Progress**, **Ready To Review**. **Done tidak pernah** masuk daftar.
4. Tulis lewat Bash, gabungkan dengan isi lama (`<PREFIX>` = prefix KODE):
```bash
S=${AGENT_WORKFLOW_STATE:-$HOME/.agent-workflow}; F="$S/board-status.json"
mkdir -p "$S" && { [ -s "$F" ] || echo '{}' > "$F"; } &&
jq '. + {"WEB":{"platform":"github-project","project":"PVT_xxx","field":"PVTSSF_xxx","allow":["opt1","opt2","opt3"],"names":{"opt1":"Todo","opt2":"In Progress","opt3":"Ready To Review"}}}' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
```
Bentuk entri per platform:
| Platform | Entri |
|---|---|
| `jira` | `{"platform":"jira","allow":["11","21","31"],"names":{...}}` (id transisi) |
| `github-project` | `{"platform":"github-project","project":"PVT_..","field":"PVTSSF_..","allow":[opsi],"names":{...}}` |
| `github-labels`, `gitlab-board` | `{"platform":"gitlab-board","label_prefix":"status::","allow":["status::todo","status::in-progress","status::review"],"names":{...}}` |
| lainnya | `{"platform":"linear", ...}` — guard belum memeriksanya; agen tetap tidak pernah memilih Done |

Untuk Jira, guard juga membaca `jira-transitions.json` milik kit Mobile bila project belum ada di `board-status.json`.

## Yang dijaga guard
- Menutup issue (`gh issue close`, `glab issue close`, MCP `state: closed`) = Done → diblokir.
- Status hanya ke nilai di `board-status.json` (Jira, GitHub Projects, label status).
- Mode audit: semua tulisan ke platform tiket diblokir.
- Tidak tertangkap guard (tanggung jawab agen): `gh api graphql` yang mengubah field project, dan kata `Closes #n` di PR yang di-merge ke branch default.
