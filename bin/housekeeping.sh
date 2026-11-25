#!/usr/bin/env bash
# Hourly (launchd on macOS, cron on Linux): decides daily / weekly / emergency cleanup of
# rebuildable web caches. Only touches folders under $HOME listed in ~/.agent-workflow/build-roots.txt
# (one project folder per line) plus ${TMPDIR:-/tmp}/qa.
#   daily  (>= 03:00): playwright-report/ + test-results/ older than 7 days, /tmp/qa children > 7 days
#   weekly (Sunday >= 03:30): framework caches > 7 days (.next/cache, .turbo, .vite, .parcel-cache,
#          node_modules/.cache), node_modules of ticket worktrees (<repo>-<nomor>) idle > 14 days,
#          npm/pnpm/yarn cache
#   emergency (< 20 GB free): daily + light, notify once per day when still low
# Skips while busy: a live deploy:* lock or a running build/deploy/e2e process.
# Overrides (tests): HK_NOW HK_FREE_GB HK_BUSY HK_NOTIFY NPM PNPM YARN AGENT_LOCK_DIR
set -u
[ -n "${HOME:-}" ] || { echo "housekeeping: HOME is empty" >&2; exit 1; }
AW="$HOME/.agent-workflow"; STATE="$AW/state"; LOG="$AW/logs/housekeeping-frontend.log"
mkdir -p "$STATE" "$AW/logs"
NOW=${HK_NOW:-$(date +%s)}; NOW_REAL=$(date +%s)
NPM=${NPM:-npm}; PNPM=${PNPM:-pnpm}; YARN=${YARN:-yarn}
QA_TMP="${TMPDIR:-/tmp}"; QA_TMP="${QA_TMP%/}/qa"
LOW_GB=20
FAILS=0

fmt() { date -r "$1" "+$2" 2>/dev/null || date -d "@$1" "+$2"; }   # BSD, then GNU
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }  # GNU first
log() { echo "$(fmt "$NOW" '%F %T') $*" >> "$LOG"; }
fail() { log "ERROR $*"; FAILS=$((FAILS+1)); }
notify() {
  if [ -n "${HK_NOTIFY:-}" ]; then "$HK_NOTIFY" "$1"
  elif [ "$(uname)" = Darwin ]; then osascript -e 'on run a' -e 'display notification (item 1 of a) with title "housekeeping frontend"' -e 'end run' "$1"
  elif command -v notify-send >/dev/null 2>&1; then notify-send "housekeeping frontend" "$1"
  else log "NOTICE $1"; fi
}
safe() { # path must be a clean path under $HOME
  case "$1" in *..*) return 1;; esac
  case "$1" in "$HOME"/?*) return 0;; esac
  return 1
}
prune() { # dir days [name-glob]: delete direct children older than N days
  local d=$1 n=$2 g=${3:-*}
  [ -d "$d" ] || return 0
  find "$d" -mindepth 1 -maxdepth 1 -name "$g" -mtime +"$n" -exec rm -rf {} + 2>/dev/null || fail "prune $d"
  log "pruned $d >${n}d"
}
tool() { # cmd args...: run if installed, log failures
  local c=$1; shift
  command -v "$c" >/dev/null 2>&1 || return 0
  "$c" "$@" >>"$LOG" 2>&1 || { fail "failed (exit $?): $c $*"; return 0; }
  log "ran $c $*"
}
free_gb() { echo "${HK_FREE_GB:-$(df -Pk / | awk 'NR==2{print int($4/1048576)}')}"; }
busy() {
  [ "${HK_BUSY:-}" = 1 ] && return 0
  local d pid
  for d in "${AGENT_LOCK_DIR:-$AW/locks}"/deploy%3A*; do
    [ -d "$d" ] || continue
    pid=$(cat "$d/pid" 2>/dev/null)
    if [ -n "$pid" ]; then kill -0 "$pid" 2>/dev/null && return 0
    elif [ $((NOW_REAL - $(mtime "$d"))) -lt 10 ]; then return 0; fi  # same stale rule as lock.sh
  done
  [ -n "${HK_BUSY:-}" ] && return 1  # explicit 0 skips the process check
  pgrep -f 'next build|vite build|webpack|playwright test|vercel|netlify deploy' >/dev/null 2>&1
}
ROOTS=() ROOTS_READ=''
roots() { # fills ROOTS once (main shell, so fail() counts): safe build roots from build-roots.txt
  local list="$AW/build-roots.txt" r
  [ -n "$ROOTS_READ" ] && return 0; ROOTS_READ=1
  [ -f "$list" ] || return 0
  while IFS= read -r r || [ -n "$r" ]; do
    r=${r%"${r##*[![:space:]]}"}  # strip trailing whitespace/CR
    case "$r" in ''|'#'*) continue;; esac
    safe "$r" || { fail "REFUSE build root $r"; continue; }
    [ -d "$r" ] && ROOTS+=("$r")
  done < "$list"
  return 0
}

daily() {
  local r
  roots
  for r in ${ROOTS[@]+"${ROOTS[@]}"}; do
    find "$r" -maxdepth 6 -name node_modules -prune -o -type d \( -name playwright-report -o -name test-results \) \
      -mtime +7 -prune -exec rm -rf {} + 2>/dev/null || fail "test reports $r"
    log "pruned old test reports $r"
  done
  [ -d "$QA_TMP" ] && prune "$QA_TMP" 7
  return 0
}
weekly() {
  local r w c
  roots
  for r in ${ROOTS[@]+"${ROOTS[@]}"}; do
    for c in .next/cache .turbo .vite .parcel-cache node_modules/.cache; do
      while IFS= read -r w; do prune "$w" 7; done < <(find "$r" -maxdepth 5 -path "*/node_modules/*/node_modules" -prune -o -type d -path "*/$c" -print 2>/dev/null)
    done
    # node_modules of ticket worktrees (<repo>-<nomor>) idle for 14 days: reinstall is cheap
    for w in "$r"/*/; do
      w=${w%/}
      [[ ${w##*/} =~ -[0-9]+$ ]] && [ -d "$w/node_modules" ] && [ -e "$w/.git" ] || continue
      if [ $((NOW - $(mtime "$w/.git"))) -gt $((14 * 86400)) ]; then
        rm -rf "$w/node_modules" 2>/dev/null || fail "node_modules $w"
        log "removed idle node_modules $w"
      fi
    done
  done
  light
}
light() { # safe while a build runs: nothing a build reads
  tool "$NPM" cache clean --force
  tool "$PNPM" store prune
  tool "$YARN" cache clean
}
low_disk() { # once per day
  if [ "$(free_gb)" -lt "$LOW_GB" ] && [ ! -e "$STATE/fe-lowdisk-$today" ]; then
    touch "$STATE/fe-lowdisk-$today"; log "still low: $(free_gb) GB"
    notify "Disk masih di bawah $LOW_GB GB setelah pembersihan ($(free_gb) GB kosong)"
  fi
}

today=$(fmt "$NOW" %F); hm=$(fmt "$NOW" %H%M); dow=$(fmt "$NOW" %u)
if busy; then
  log "busy, skipping"
  if [ "$(free_gb)" -lt "$LOW_GB" ] && [ ! -e "$STATE/fe-emergency-$today" ]; then
    touch "$STATE/fe-emergency-$today"; log "emergency while busy: free $(free_gb) GB, light cleanup"
    light; low_disk
  fi
  last=$(cat "$STATE/fe-daily" 2>/dev/null)
  if [ -n "$last" ] && [ "$last" != "$today" ] && [ "$last" != "$(fmt $((NOW - 86400)) %F)" ] \
    && [ ! -e "$STATE/fe-skipnote-$today" ]; then
    touch "$STATE/fe-skipnote-$today"
    notify "housekeeping frontend dilewati sejak $last karena build/deploy terus berjalan; cek $LOG"
  fi
  [ "$FAILS" -gt 0 ] && notify "housekeeping frontend: $FAILS error, lihat $LOG"
  exit 0
fi
did_daily=0
if [ "$hm" -ge 0300 ] 2>/dev/null && [ "$(cat "$STATE/fe-daily" 2>/dev/null)" != "$today" ]; then
  daily; did_daily=1; echo "$today" > "$STATE/fe-daily"
fi
if [ "$dow" = 7 ] && [ "$hm" -ge 0330 ] && [ "$(cat "$STATE/fe-weekly" 2>/dev/null)" != "$today" ]; then
  weekly; echo "$today" > "$STATE/fe-weekly"
fi
if [ "$(free_gb)" -lt "$LOW_GB" ] && [ ! -e "$STATE/fe-emergency-$today" ]; then
  log "emergency: free $(free_gb) GB"
  touch "$STATE/fe-emergency-$today"
  [ "$did_daily" = 1 ] || daily
  light
  low_disk
fi
[ "$FAILS" -gt 0 ] && notify "housekeeping frontend: $FAILS error, lihat $LOG"
exit 0
