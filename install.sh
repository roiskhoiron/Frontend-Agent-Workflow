#!/usr/bin/env bash
# Usage: install.sh [--agent LIST] [--scope global|project] [--project DIR] [--home DIR] [--force] [--yes]
#   --agent   claude, codex, gemini, copilot, cursor, opencode, generic (comma-separated) or all
#   --scope   global  = for every project of this user (under $HOME)
#             project = only for one project folder (--project DIR, default: current folder)
#   --home    another home folder (tests); --force replaces other kits' symlinks (never real files)
#   --yes     no questions. Without --agent/--scope on a terminal, install.sh asks; otherwise
#             the defaults are --agent claude --scope global (the original behaviour).
# Per agent it installs skills (symlinks), the safety guard as that agent's pre-tool hook (where
# the agent has hooks), and the kit's instruction block once in the agent's instruction file.
# Always: ~/.agent-workflow/frontend-kit -> this repo (the path every skill uses), logs dir,
# housekeeping schedule (launchd on macOS; crontab hint on Linux). Idempotent.
# Exit: 0 ok; 1 conflict (another kit's symlink or a real file where a link should go); 2 usage.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd -P)"
ALL_AGENTS="claude codex gemini copilot cursor opencode generic"
HOMED="$HOME"; CUSTOM=0; FORCE=0; YES=0; AGENTS=""; SCOPE=""; PROJ=""
usage() { echo "usage: $0 [--agent LIST|all] [--scope global|project] [--project DIR] [--home DIR] [--force] [--yes]" >&2; exit 2; }
while [ $# -gt 0 ]; do
  case $1 in
    --agent|--agents) AGENTS="${2:-}"; shift 2 || usage;;
    --agent=*|--agents=*) AGENTS="${1#*=}"; shift;;
    --scope) SCOPE="${2:-}"; shift 2 || usage;;
    --scope=*) SCOPE="${1#*=}"; shift;;
    --project) PROJ="${2:-}"; SCOPE=${SCOPE:-project}; shift 2 || usage;;
    --home) HOMED="${2:?--home butuh folder}"; CUSTOM=1; shift 2;;
    --force) FORCE=1; shift;;
    --yes|-y) YES=1; shift;;
    -h|--help) sed -n '2,13p' "$0"; exit 0;;
    *) usage;;
  esac
done

# --- questions (only on a terminal, only for what was not given) -----------------------------
if [ "$YES" = 0 ] && [ -t 0 ] && { [ -z "$AGENTS" ] || [ -z "$SCOPE" ]; }; then
  if [ -z "$AGENTS" ]; then
    echo "Agen coding mana yang dipakai? (boleh lebih dari satu, pisahkan koma, mis. 1,3)"
    i=0; for a in $ALL_AGENTS; do i=$((i+1)); printf '  %d) %s\n' "$i" "$a"; done
    echo "  8) semua"
    printf 'Pilihan [1]: '; read -r ans; ans=${ans:-1}
    AGENTS=""
    for n in $(echo "$ans" | tr ',' ' '); do
      [ "$n" = 8 ] && { AGENTS=all; break; }
      i=0; for a in $ALL_AGENTS; do i=$((i+1)); [ "$i" = "$n" ] && AGENTS="$AGENTS,$a"; done
    done
    AGENTS=${AGENTS#,}; [ -n "$AGENTS" ] || { echo "Pilihan tidak dikenal: $ans" >&2; exit 2; }
  fi
  if [ -z "$SCOPE" ]; then
    echo "Pasang untuk siapa?"
    echo "  1) global  - semua project di komputer ini"
    echo "  2) project - satu folder project saja"
    printf 'Pilihan [1]: '; read -r ans
    case ${ans:-1} in 1|global) SCOPE=global;; 2|project) SCOPE=project;; *) echo "Pilihan tidak dikenal: $ans" >&2; exit 2;; esac
    if [ "$SCOPE" = project ] && [ -z "$PROJ" ]; then
      printf 'Folder project [%s]: ' "$PWD"; read -r PROJ
    fi
  fi
fi
AGENTS=${AGENTS:-claude}; SCOPE=${SCOPE:-global}
[ "$AGENTS" = all ] && AGENTS=$(echo $ALL_AGENTS | tr ' ' ',')
SEL=""
for a in $(echo "$AGENTS" | tr ',' ' '); do
  case " $ALL_AGENTS " in *" $a "*) case " $SEL " in *" $a "*) ;; *) SEL="$SEL $a";; esac;; *) echo "agen tidak dikenal: $a (pilih: $ALL_AGENTS, all)" >&2; exit 2;; esac
done
case $SCOPE in
  global) BASE="$HOMED";;
  project) PROJ=${PROJ:-$PWD}; [ -d "$PROJ" ] || { echo "folder project tidak ada: $PROJ" >&2; exit 2; }; BASE="$(cd "$PROJ" && pwd -P)";;
  *) usage;;
esac
has() { case " $SEL " in *" $1 "*) return 0;; esac; return 1; }

# --- planned symlinks "<source>|<target>" ------------------------------------------------------
links=()
add_skills() { # target-dir
  local d
  for d in "$REPO"/skills/*/; do
    [ -d "$d" ] || continue
    [ "$(basename "$d")" = _shared ] && continue
    links+=("${d%/}|$1/$(basename "$d")")
  done
}
has claude && { add_skills "$BASE/.claude/skills"; for f in "$REPO"/agents/*.md; do [ -e "$f" ] && links+=("$f|$BASE/.claude/agents/$(basename "$f")"); done; }
for a in codex gemini copilot cursor opencode generic; do has $a && { add_skills "$BASE/.agents/skills"; break; }; done

hard=() soft=()
for l in ${links[@]+"${links[@]}"}; do
  t=${l#*|}
  if [ -L "$t" ]; then
    case "$(readlink "$t")" in "$REPO"/*) ;; *) soft+=("$t -> $(readlink "$t")");; esac
  elif [ -e "$t" ]; then
    hard+=("$t")
  fi
done
if [ ${#hard[@]} -gt 0 ] || { [ ${#soft[@]} -gt 0 ] && [ "$FORCE" = 0 ]; }; then
  echo "Tidak dipasang: nama skill/agen ini sudah dipakai kit lain atau file sendiri:" >&2
  for x in ${soft[@]+"${soft[@]}"}; do echo "  link kit lain: $x" >&2; done
  for x in ${hard[@]+"${hard[@]}"}; do echo "  file/folder asli (tidak pernah dihapus): $x" >&2; done
  [ ${#hard[@]} -gt 0 ] && echo "Pindahkan file/folder asli itu sendiri dulu." >&2
  [ ${#soft[@]} -gt 0 ] && echo "Satu komputer satu kit untuk perintah yang sama. Ganti ke kit frontend: jalankan lagi dengan --force." >&2
  exit 1
fi
for l in ${links[@]+"${links[@]}"}; do mkdir -p "$(dirname "${l#*|}")"; ln -sfn "${l%%|*}" "${l#*|}"; done
# v1 linked skills/_shared as a skill; the shared docs now live behind ~/.agent-workflow/frontend-kit
old="$BASE/.claude/skills/_frontend-workflow-shared"
[ -L "$old" ] && case "$(readlink "$old")" in "$REPO"/*) rm -f "$old";; esac

# --- kit pointer, logs, housekeeping (machine-wide) --------------------------------------------
AW="$HOMED/.agent-workflow"; mkdir -p "$AW/logs" "$AW/projects"
if [ -L "$AW/frontend-kit" ] && [ "$(readlink "$AW/frontend-kit")" != "$REPO" ]; then
  echo "catatan: ~/.agent-workflow/frontend-kit dipindah dari $(readlink "$AW/frontend-kit") ke $REPO"
fi
ln -sfn "$REPO" "$AW/frontend-kit"
P="$REPO/launchd/com.frontendworkflow.housekeeping.plist"
if [ "$(uname)" = Darwin ] && [ -f "$P" ]; then
  out="$HOMED/Library/LaunchAgents/$(basename "$P")"
  mkdir -p "$(dirname "$out")"
  sed -e "s|__FRONTEND_WORKFLOW_DIR__|$REPO|g" -e "s|__HOME__|$HOMED|g" "$P" > "$out"
  if [ "$CUSTOM" = 0 ]; then
    launchctl bootout "gui/$(id -u)" "$out" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$out"
  fi
else
  echo "Linux: tambahkan pembersihan berkala lewat 'crontab -e': 17 * * * * /bin/bash \"$REPO/bin/housekeeping.sh\""
fi

# --- hooks (guard) --------------------------------------------------------------------------
created=()   # files this run created in a project (kept out of git, they hold local paths)
json_file() { # path: make sure it exists as JSON, back up the first original
  mkdir -p "$(dirname "$1")"
  if [ -f "$1" ]; then [ -e "$1.bak-frontend-workflow" ] || cp "$1" "$1.bak-frontend-workflow"
  else echo '{}' > "$1"; created+=("$1"); fi
}
jq_inplace() { local f=$1 tmp; shift; tmp=$(mktemp); jq "$@" "$f" > "$tmp" && mv "$tmp" "$f"; }
ADP="\"$REPO/hooks/guard-adapter.sh\""
notes=()

if has claude; then
  S="$BASE/.claude/settings.json"; [ "$SCOPE" = project ] && S="$BASE/.claude/settings.local.json"
  json_file "$S"
  jq_inplace "$S" --arg cmd "\"$REPO/hooks/guard-frontend.sh\"" --arg m 'Bash|Edit|Write|MultiEdit|NotebookEdit|mcp__.*Atlassian.*__.*|mcp__.*[Gg]it[HhLl][a-z]*__.*' '
    def isguard: any((.hooks // [])[]?; .command | tostring | test("/guard-frontend\\.sh\"?$"));
    .hooks.PreToolUse = ((.hooks.PreToolUse // [])
      | if any(.[]; isguard) then map(if isguard then .matcher = $m | .hooks = [{type:"command",command:$cmd}] else . end)
        else . + [{matcher:$m, hooks:[{type:"command",command:$cmd}]}] end)'
fi
if has codex; then
  F="$BASE/.codex/hooks.json"; json_file "$F"
  jq_inplace "$F" --arg cmd "$ADP codex" '
    def mine: any((.hooks // [])[]?; .command | tostring | test("guard-adapter\\.sh\"? codex$"));
    .hooks.PreToolUse = (((.hooks.PreToolUse // []) | map(select(mine | not))) + [{matcher:"Bash", hooks:[{type:"command",command:$cmd,statusMessage:"frontend guard"}]}])'
  [ "$SCOPE" = project ] && notes+=("codex: hook project (.codex/hooks.json) baru jalan setelah project di-trust di Codex.")
fi
if has gemini; then
  F="$BASE/.gemini/settings.json"; json_file "$F"
  jq_inplace "$F" --arg cmd "$ADP gemini" '
    def mine: any((.hooks // [])[]?; .command | tostring | test("guard-adapter\\.sh\"? gemini$"));
    .hooks.BeforeTool = (((.hooks.BeforeTool // []) | map(select(mine | not))) + [{matcher:"run_shell_command|write_file|replace", hooks:[{name:"frontend-guard",type:"command",command:$cmd,timeout:15000}]}])'
fi
if has copilot; then
  F="$HOMED/.copilot/hooks/frontend-workflow.json"; [ "$SCOPE" = project ] && F="$BASE/.github/hooks/frontend-workflow.json"
  [ -f "$F" ] || created+=("$F")
  mkdir -p "$(dirname "$F")"
  jq -n --arg cmd "$ADP copilot" '{version:1, hooks:{preToolUse:[{type:"command", bash:$cmd, timeoutSec:30}]}}' > "$F"
fi
if has cursor; then
  F="$BASE/.cursor/hooks.json"; json_file "$F"
  jq_inplace "$F" --arg cmd "$ADP cursor" '
    def mine: (.command // "" | tostring | test("guard-adapter\\.sh\"? cursor$"));
    .version = (.version // 1) | .hooks.beforeShellExecution = (((.hooks.beforeShellExecution // []) | map(select(mine | not))) + [{command:$cmd}])'
  notes+=("cursor: pagar hanya untuk perintah shell (beforeShellExecution); edit file di worktree primary tidak dicegat.")
fi
has opencode && notes+=("opencode: belum ada pagar otomatis (cara memblokir lewat plugin belum terdokumentasi); aturan di rules.md tetap wajib ditaati agen.")
has generic && notes+=("generic: belum ada pagar otomatis; agen harus menaati aturan di rules.md.")

# --- instruction block (once per file) -------------------------------------------------------
T="$REPO/templates/agent-instructions.md"
ifiles=""
add_if() { case " $ifiles " in *" $1 "*) ;; *) ifiles="$ifiles $1";; esac; }
for a in $SEL; do
  if [ "$SCOPE" = global ]; then
    case $a in
      claude) add_if "$HOMED/.claude/CLAUDE.md";;
      codex) add_if "$HOMED/.codex/AGENTS.md";;
      gemini) add_if "$HOMED/.gemini/GEMINI.md";;
      opencode) add_if "$HOMED/.config/opencode/AGENTS.md";;
      copilot|cursor|generic) notes+=("$a: tidak ada file instruksi global yang pasti; pasang juga dengan --scope project agar AGENTS.md project memuat blok kit.");;
    esac
  else
    case $a in
      claude) add_if "$BASE/CLAUDE.md";;
      gemini) add_if "$BASE/GEMINI.md";;
      *) add_if "$BASE/AGENTS.md";;
    esac
  fi
done
if [ -f "$T" ]; then
  for f in $ifiles; do
    mkdir -p "$(dirname "$f")"
    grep -qs '^# Frontend agent workflow' "$f" || { { [ -s "$f" ] && echo; cat "$T"; } >> "$f"; }
  done
fi

# --- project scope: keep machine-local links/configs out of git ------------------------------
if [ "$SCOPE" = project ] && git -C "$BASE" rev-parse --git-dir >/dev/null 2>&1; then
  ex=$(git -C "$BASE" rev-parse --git-path info/exclude); case $ex in /*) ;; *) ex="$BASE/$ex";; esac
  mkdir -p "$(dirname "$ex")"; touch "$ex"
  for l in ${links[@]+"${links[@]}"} ${created[@]+"${created[@]}"}; do
    p=${l#*|}; p=${p#"$BASE"/}
    git -C "$BASE" ls-files --error-unmatch "$p" >/dev/null 2>&1 && continue
    grep -qxF "/$p" "$ex" || echo "/$p" >> "$ex"
  done
fi

echo "terpasang: agen [${SEL# }], scope $SCOPE ($BASE)"
for n in ${notes[@]+"${notes[@]}"}; do echo "catatan: $n"; done
if [ "$SCOPE" = project ] && [ -n "$ifiles" ]; then echo "Commit file instruksi yang diubah bila ingin dipakai tim:$ifiles"; fi
exit 0
