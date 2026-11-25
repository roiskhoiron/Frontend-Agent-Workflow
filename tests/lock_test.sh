#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
L="$REPO/bin/lock.sh"
export AGENT_LOCK_DIR=$(mktemp -d); trap 'rm -rf "$AGENT_LOCK_DIR"' EXIT
sleep 300 & LIVE=$!; trap 'kill $LIVE 2>/dev/null; rm -rf "$AGENT_LOCK_DIR"' EXIT
DEAD=$(sh -c 'echo $$')

assert_exit 0 "acquire free" -- env AGENT_LOCK_PID=$LIVE "$L" acquire port:4100 P-1-coder1
assert_eq P-1-coder1 "$("$L" who port:4100)" "who prints owner"
assert_eq "$LIVE" "$(cat "$AGENT_LOCK_DIR/port%3A4100/pid")" "pid recorded from AGENT_LOCK_PID"
assert_exit 0 "same owner re-acquires" -- env AGENT_LOCK_PID=$LIVE "$L" acquire port:4100 P-1-coder1
assert_eq P-1-coder1 "$(AGENT_LOCK_PID=$$ "$L" acquire port:4100 P-2-qa1)" "held: prints holder"
assert_exit 1 "held by live pid: exit 1" -- env AGENT_LOCK_PID=$$ "$L" acquire port:4100 P-2-qa1
"$L" release port:4100 P-2-qa1
assert_eq P-1-coder1 "$("$L" who port:4100)" "release by other owner ignored"
"$L" release port:4100 P-1-coder1
assert_eq "" "$("$L" who port:4100)" "release by owner frees"
# stale: dead pid reclaimed
AGENT_LOCK_PID=$DEAD "$L" acquire deploy:staging P-1-release1
assert_exit 0 "dead pid reclaimed" -- env AGENT_LOCK_PID=$$ "$L" acquire deploy:staging P-3-release1
assert_eq P-3-release1 "$("$L" who deploy:staging)" "new owner after reclaim"
# empty pid: held while fresh, free when old
mkdir -p "$AGENT_LOCK_DIR/account%3Aqa.user1"; echo X > "$AGENT_LOCK_DIR/account%3Aqa.user1/owner"
assert_exit 1 "fresh lock without pid = held" -- "$L" acquire account:qa.user1 Y
touch -t 202001010000 "$AGENT_LOCK_DIR/account%3Aqa.user1"
assert_exit 0 "old lock without pid = stale" -- env AGENT_LOCK_PID=$$ "$L" acquire account:qa.user1 Y
# encoding
AGENT_LOCK_PID=$$ "$L" acquire checkout:/a/b P-1
assert_eq yes "$([ -d "$AGENT_LOCK_DIR/checkout%3A%2Fa%2Fb" ] && echo yes)" "/ and : encoded"
assert_exit 0 "checkout:/a%2Fb is a different resource" -- env AGENT_LOCK_PID=$$ "$L" acquire 'checkout:/a%2Fb' P-2
# move
assert_exit 1 "move without from-owner fails" -- env AGENT_LOCK_PID=$LIVE "$L" move port:4100 "" x
AGENT_LOCK_PID=$$ "$L" acquire port:4101 qa1
assert_exit 0 "move from owner" -- env AGENT_LOCK_PID=$LIVE "$L" move port:4101 qa1 human-P-1
assert_eq human-P-1 "$("$L" who port:4101)" "moved owner"
assert_eq "$LIVE" "$(cat "$AGENT_LOCK_DIR/port%3A4101/pid")" "moved pid"
assert_exit 1 "move from non-owner fails" -- "$L" move port:4101 qa1 z
assert_exit 2 "usage" -- "$L" bogus x
echo "lock_test FAILS=$FAILS"; exit $FAILS
