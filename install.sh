#!/usr/bin/env bash
# Usage: install.sh [--home DIR] [--force]   (default $HOME). Idempotent.
# Links skills/* and agents/*.md into ~/.claude, adds the guard-frontend.sh PreToolUse hook,
# schedules housekeeping (launchd on macOS; cron hint on Linux), appends the global CLAUDE.md section once.
# A skill/agent name already linked to another kit (e.g. the mobile kit's /validate-tiket or spv.md),
# or a real file/dir with that name, is a conflict: refuse (exit 1). --force replaces other kits'
# symlinks only; real files/dirs are never deleted.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd -P)"
DEST="$HOME"; CUSTOM=0; FORCE=0
while [ $# -gt 0 ]; do
  case $1 in
    --home) DEST="${2:?--home butuh folder}"; CUSTOM=1; shift 2;;
    --force) FORCE=1; shift;;
    *) echo "usage: $0 [--home DIR] [--force]" >&2; exit 2;;
  esac
done
C="$DEST/.claude"
mkdir -p "$C/skills" "$C/agents"

# planned links: "<source>|<target>"
links=()
for d in "$REPO"/skills/*/; do
  [ -d "$d" ] || continue
  n=$(basename "$d"); [ "$n" = _shared ] && n=_frontend-workflow-shared
  links+=("${d%/}|$C/skills/$n")
done
for f in "$REPO"/agents/*.md; do
  [ -e "$f" ] && links+=("$f|$C/agents/$(basename "$f")")
done

# conflicts: something there that is not already a link into this repo
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
for l in ${links[@]+"${links[@]}"}; do ln -sfn "${l%%|*}" "${l#*|}"; done

S="$C/settings.json"
[ -f "$S" ] || echo '{}' > "$S"
[ -e "$S.bak-frontend-workflow" ] || cp "$S" "$S.bak-frontend-workflow"  # keep the first original
tmp=$(mktemp)
jq --arg cmd "\"$REPO/hooks/guard-frontend.sh\"" --arg m 'Bash|Edit|Write|MultiEdit|NotebookEdit|mcp__.*Atlassian.*__.*' '
  def isguard: any((.hooks // [])[]?; .command | tostring | test("/guard-frontend\\.sh\"?$"));
  .hooks.PreToolUse = ((.hooks.PreToolUse // [])
    | if any(.[]; isguard) then map(if isguard then .matcher = $m | .hooks = [{type:"command",command:$cmd}] else . end)
      else . + [{matcher:$m, hooks:[{type:"command",command:$cmd}]}] end)' "$S" > "$tmp"
mv "$tmp" "$S"

mkdir -p "$DEST/.agent-workflow/logs"
P="$REPO/launchd/com.frontendworkflow.housekeeping.plist"
if [ "$(uname)" = Darwin ] && [ -f "$P" ]; then
  out="$DEST/Library/LaunchAgents/$(basename "$P")"
  mkdir -p "$(dirname "$out")"
  sed -e "s|__FRONTEND_WORKFLOW_DIR__|$REPO|g" -e "s|__HOME__|$DEST|g" "$P" > "$out"
  if [ "$CUSTOM" = 0 ]; then
    launchctl bootout "gui/$(id -u)" "$out" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$out"
  fi
else
  echo "Linux: tambahkan pembersihan berkala lewat 'crontab -e': 17 * * * * /bin/bash \"$REPO/bin/housekeeping.sh\""
fi

# global CLAUDE.md section, appended once
T="$REPO/templates/claude-global.md"
if [ -f "$T" ] && ! grep -qs '^# Frontend agent workflow' "$C/CLAUDE.md"; then
  { [ -s "$C/CLAUDE.md" ] && echo; cat "$T"; } >> "$C/CLAUDE.md"
fi
echo "terpasang di $DEST"
