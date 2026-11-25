#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
P="$REPO/bin/port-pick.sh"
T=$(mktemp -d)
sleep 300 & LIVE=$!; trap 'kill $LIVE 2>/dev/null; rm -rf "$T"' EXIT
export AGENT_LOCK_DIR="$T/locks" AGENT_LOCK_PID=$LIVE
# fake lsof: ports listed in $T/listening are "in use"
printf '#!/bin/sh\nfor a; do case $a in -iTCP:*) p=${a#-iTCP:};; esac; done\ngrep -qx "$p" "%s/listening" 2>/dev/null\n' "$T" > "$T/lsof"; chmod +x "$T/lsof"
export LSOF="$T/lsof"
: > "$T/listening"

assert_eq 4100 "$("$P" P-1-coder1)" "first free port"
assert_eq P-1-coder1 "$(cat "$AGENT_LOCK_DIR/port%3A4100/owner")" "port locked for owner"
assert_eq 4100 "$("$P" P-1-coder1)" "same owner: same port (idempotent)"
assert_eq 4101 "$("$P" P-2-qa1)" "next owner: next port"
echo 4102 > "$T/listening"
assert_eq 4103 "$("$P" P-3-qa2)" "listening port skipped"
assert_eq 5000 "$("$P" X 5000 5000)" "custom range"
assert_exit 1 "range exhausted" -- "$P" Y 5000 5000
# dead holder: port reusable
sh -c 'echo $$' > "$AGENT_LOCK_DIR/port%3A5000/pid"
assert_eq 5000 "$("$P" Y 5000 5000)" "dead holder reclaimed"
assert_exit 2 "no owner" -- "$P"
assert_exit 2 "bad range" -- "$P" Z 10 5
assert_exit 2 "non-numeric" -- "$P" Z abc
# python bind fallback (no lsof)
python3 -c 'import socket,time,sys
s=socket.socket(); s.bind(("127.0.0.1",0)); s.listen(); print(s.getsockname()[1]); sys.stdout.flush(); time.sleep(30)' > "$T/bound" & SRV=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do [ -s "$T/bound" ] && break; sleep 0.2; done
B=$(cat "$T/bound")
assert_exit 1 "bind fallback: listening port not picked" -- env LSOF= "$P" W "$B" "$B"
kill $SRV 2>/dev/null
echo "port_pick_test FAILS=$FAILS"; exit $FAILS
