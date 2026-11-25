#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
H="$REPO/bin/housekeeping.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export HOME="$T/home" TMPDIR="$T/tmp"; mkdir -p "$HOME" "$TMPDIR"
export AGENT_LOCK_DIR="$T/locks" HK_BUSY=0 HK_FREE_GB=200
export HK_NOTIFY="$T/notify.sh"
printf '#!/bin/sh\necho "$1" >> "%s/notified"\n' "$T" > "$T/notify.sh"; chmod +x "$T/notify.sh"
CALLS="$T/calls"
for n in npm pnpm yarn; do
  printf '#!/bin/sh\necho "%s $*" >> "%s"\n' "$n" "$CALLS" > "$T/$n"; chmod +x "$T/$n"
done
export NPM="$T/npm" PNPM="$T/pnpm" YARN="$T/yarn"
OLD=202001010000
P="$HOME/proj"; S="$HOME/.agent-workflow/state"; LOG="$HOME/.agent-workflow/logs/housekeeping-frontend.log"
ts() { date -d "$1" +%s 2>/dev/null || date -j -f '%Y-%m-%d %H:%M' "$1" +%s; }   # local time -> epoch
old() { mkdir -p "$1"; touch -t $OLD "$1"; }
yes_if() { [ -e "$1" ] && echo yes; }
reset() {
  rm -rf "$HOME" "$TMPDIR" "$T/notified" "$CALLS" "$T/locks"; mkdir -p "$HOME" "$TMPDIR"
  old "$P/web/playwright-report"; old "$P/web/test-results"; mkdir -p "$P/web/playwright-report-new/x"
  mkdir -p "$P/web2/test-results"                                   # fresh: kept
  old "$P/web/node_modules/pkg/test-results"                        # inside node_modules: kept
  old "$TMPDIR/qa/PROJ-1"; mkdir -p "$TMPDIR/qa/PROJ-2"
  mkdir -p "$P/web/.next/cache"; old "$P/web/.next/cache/old"; mkdir -p "$P/web/.next/cache/new"
  old "$P/web/node_modules/.cache/babel"; old "$P/web/.turbo/x"
  mkdir -p "$P/web-123/node_modules/a"; touch -t $OLD "$P/web-123/.git"   # idle ticket worktree
  mkdir -p "$P/web-124/node_modules/a"; touch "$P/web-124/.git"           # active ticket worktree
  mkdir -p "$P/web/src/node_modules"; touch -t $OLD "$P/web/.git"         # domain checkout: never
  mkdir -p "$HOME/.agent-workflow"; echo "$P" > "$HOME/.agent-workflow/build-roots.txt"
}
run() { HK_NOW=$(ts "$1") bash "$H"; }

reset; run "2026-10-28 02:00"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "02:00 no daily"
reset; run "2026-10-28 03:10"
assert_eq "" "$(yes_if "$P/web/playwright-report")" "daily removes old playwright-report"
assert_eq "" "$(yes_if "$P/web/test-results")" "daily removes old test-results"
assert_eq yes "$(yes_if "$P/web2/test-results")" "daily keeps fresh test-results"
assert_eq yes "$(yes_if "$P/web/node_modules/pkg/test-results")" "node_modules not searched"
assert_eq "" "$(yes_if "$TMPDIR/qa/PROJ-1")" "daily prunes old /tmp/qa child"
assert_eq yes "$(yes_if "$TMPDIR/qa/PROJ-2")" "daily keeps new /tmp/qa child"
assert_eq yes "$(yes_if "$P/web/.next/cache/old")" "daily leaves framework caches"
assert_eq yes "$(yes_if "$S/fe-daily")" "daily stamp"
assert_eq "" "$(yes_if "$CALLS")" "daily runs no external tools"
old "$P/web/test-results"; run "2026-10-28 04:00"
assert_eq yes "$(yes_if "$P/web/test-results")" "daily only once per day"
run "2026-10-29 03:00"
assert_eq "" "$(yes_if "$P/web/test-results")" "daily next day runs"
# busy
reset; HK_BUSY=1 run "2026-10-28 03:10"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "busy: nothing deleted"
assert_eq "" "$(yes_if "$S/fe-daily")" "busy: no stamp"
DL="$T/locks/deploy%3Astaging"
reset; mkdir -p "$DL"; echo $$ > "$DL/pid"; run "2026-10-28 03:10"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "deploy lock with live pid = busy"
reset; mkdir -p "$DL"; sh -c 'echo $$' > "$DL/pid"; run "2026-10-28 03:10"
assert_eq "" "$(yes_if "$P/web/playwright-report")" "deploy lock with dead pid ignored"
reset; mkdir -p "$T/locks/port%3A4100"; echo $$ > "$T/locks/port%3A4100/pid"; run "2026-10-28 03:10"
assert_eq "" "$(yes_if "$P/web/playwright-report")" "port lock (idle dev server) is not busy"
# weekly, Sunday 2026-11-01
reset; run "2026-11-01 03:10"
assert_eq "" "$(yes_if "$S/fe-weekly")" "Sunday 03:10 no weekly yet"
run "2026-11-01 03:40"
assert_eq "" "$(yes_if "$P/web/.next/cache/old")" "weekly prunes old .next/cache child"
assert_eq yes "$(yes_if "$P/web/.next/cache/new")" "weekly keeps new .next/cache child"
assert_eq "" "$(yes_if "$P/web/node_modules/.cache/babel")" "weekly prunes node_modules/.cache"
assert_eq "" "$(yes_if "$P/web/.turbo/x")" "weekly prunes .turbo"
assert_eq "" "$(yes_if "$P/web-123/node_modules")" "idle ticket worktree node_modules removed"
assert_eq yes "$(yes_if "$P/web-124/node_modules")" "active ticket worktree kept"
assert_eq yes "$(yes_if "$P/web/src/node_modules")" "non-ticket checkout node_modules kept"
for c in "npm cache clean --force" "pnpm store prune" "yarn cache clean"; do
  assert_eq 1 "$(grep -cx "$c" "$CALLS")" "weekly ran: $c"
done
rm "$CALLS"; run "2026-11-01 05:00"
assert_eq "" "$(yes_if "$CALLS")" "weekly once per week"
# emergency
reset; mkdir -p "$S"; echo 2026-10-28 > "$S/fe-daily"; HK_FREE_GB=10 run "2026-10-28 10:00"
assert_eq "" "$(yes_if "$P/web/playwright-report")" "emergency runs daily cleanup"
assert_eq 1 "$(grep -cx "npm cache clean --force" "$CALLS")" "emergency runs light"
assert_eq yes "$([ -s "$T/notified" ] && echo yes)" "still low -> notified"
old "$P/web/playwright-report"; rm "$T/notified"; HK_FREE_GB=10 run "2026-10-28 11:00"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "emergency once per day"
assert_eq "" "$(yes_if "$T/notified")" "low disk notified once per day"
reset; mkdir -p "$S"; echo 2026-10-28 > "$S/fe-daily"; run "2026-10-28 10:00"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "healthy disk at 10:00: nothing"
# busy emergency: light only
reset; mkdir -p "$S"; echo 2026-10-28 > "$S/fe-daily"; HK_BUSY=1 HK_FREE_GB=10 run "2026-10-28 10:00"
assert_eq yes "$(yes_if "$P/web/playwright-report")" "busy emergency: reports kept"
assert_eq 1 "$(grep -cx "pnpm store prune" "$CALLS")" "busy emergency: light ran"
# skip notice
reset; mkdir -p "$S"; echo 2026-10-26 > "$S/fe-daily"; HK_BUSY=1 run "2026-10-28 10:00"
assert_eq 1 "$(grep -c dilewati "$T/notified" 2>/dev/null)" "skipped >1 day -> notified"
HK_BUSY=1 run "2026-10-28 11:00"
assert_eq 1 "$(grep -c dilewati "$T/notified")" "skip notice once per day"
# safety
assert_exit 1 "empty HOME refused" -- env HOME= bash "$H"
old "$T/outside/test-results"
reset; printf '# c\n\n%s\r\n%s\n%s\n' "$P" "$T/outside" "$HOME/../x" > "$HOME/.agent-workflow/build-roots.txt"; run "2026-10-28 03:10"
assert_eq "" "$(yes_if "$P/web/test-results")" "CR line root processed"
assert_eq yes "$(yes_if "$T/outside/test-results")" "root outside HOME refused"
assert_eq 2 "$(grep -c REFUSE "$LOG")" "refusals logged (outside, ..)"
assert_eq yes "$([ -s "$T/notified" ] && echo yes)" "refusal notified"
reset; printf '#!/bin/sh\nexit 3\n' > "$T/npm"; run "2026-11-01 03:40"
assert_eq 1 "$(grep -c 'failed (exit 3)' "$LOG")" "tool failure logged with code"
command -v plutil >/dev/null && assert_exit 0 "plist lint" -- plutil -lint "$REPO/launchd/com.frontendworkflow.housekeeping.plist"
assert_exit 0 "plist is well-formed xml" -- python3 -c "import plistlib,sys;plistlib.load(open(sys.argv[1],'rb'))" "$REPO/launchd/com.frontendworkflow.housekeeping.plist"
echo "housekeeping_test FAILS=$FAILS"; [ "$FAILS" = 0 ]
