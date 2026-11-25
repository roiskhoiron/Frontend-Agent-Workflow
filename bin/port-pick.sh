#!/usr/bin/env bash
# Usage: port-pick.sh <owner> [from [to]]   (default 4100 4199)
# Picks a free dev-server port for one agent/worktree and locks it as `port:<n>` (bin/lock.sh).
# Free = not locked by another live owner and nothing listening on it.
# Call with AGENT_LOCK_PID=$PPID in the same Bash call; release with `lock.sh release port:<n> <owner>`.
# Same owner already holding a port in the range -> prints that port again (idempotent).
# Exit: 0 port printed; 1 no free port in range; 2 usage.
# Test override: LSOF (path of an lsof-compatible command; empty = use python bind test).
owner=$1 from=${2:-4100} to=${3:-4199}
[ -n "$owner" ] && [[ $from =~ ^[0-9]+$ ]] && [[ $to =~ ^[0-9]+$ ]] && [ "$from" -le "$to" ] && [ "$to" -le 65535 ] ||
  { echo "usage: $0 <owner> [from [to]]" >&2; exit 2; }
L="$(cd "$(dirname "$0")" && pwd -P)/lock.sh"
base=${AGENT_LOCK_DIR:-$HOME/.agent-workflow/locks}
export AGENT_LOCK_PID=${AGENT_LOCK_PID:-$PPID}
LSOF=${LSOF-$(command -v lsof)}

listening() {
  if [ -n "$LSOF" ]; then
    "$LSOF" -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
  else
    ! python3 -c 'import socket,sys
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", int(sys.argv[1])))' "$1" 2>/dev/null
  fi
}

# already ours?
for ((p = from; p <= to; p++)); do
  [ "$(cat "$base/port%3A$p/owner" 2>/dev/null)" = "$owner" ] || continue
  "$L" acquire "port:$p" "$owner" >/dev/null && { echo "$p"; exit 0; }
done
for ((p = from; p <= to; p++)); do
  listening "$p" && continue
  "$L" acquire "port:$p" "$owner" >/dev/null 2>&1 || continue
  if listening "$p"; then "$L" release "port:$p" "$owner"; continue; fi  # raced with a server start
  echo "$p"; exit 0
done
echo "tidak ada port bebas di $from-$to" >&2
exit 1
