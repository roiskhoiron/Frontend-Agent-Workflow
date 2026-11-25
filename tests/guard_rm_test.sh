#!/usr/bin/env bash
# rm -r for web projects: inside the project always; in other worktrees of the same repo and in
# folders from ~/.agent-workflow/build-roots.txt only rebuildable web artifacts; QA temp output free.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
G="$REPO/hooks/guard-frontend.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
W="$T/web"
git init -q "$W"; git -C "$W" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
check() { # expected-exit command [cwd]
  local j; j=$(jq -cn --arg c "$2" --arg d "${3:-$W}" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}')
  printf '%s' "$j" | "$G" >/dev/null 2>"$T/err"
  assert_eq "$1" "$?" "[$1] $2"
}

check 0 'rm -rf node_modules .next dist'
check 0 'rm -rf src/old'
git -C "$W" worktree add -q "$T/web-42" -b feature/PROJ-42
mkdir -p "$T/web-42/src" "$T/web-42/apps/site/.next/cache"
for a in node_modules .next .nuxt .output .svelte-kit dist build .turbo .vite .parcel-cache .cache coverage playwright-report test-results storybook-static .angular; do
  check 0 "rm -rf $T/web-42/$a"
done
check 0 "rm -rf $T/web-42/apps/site/.next/cache"
check 0 'rm -rf ../web-42/apps/site/node_modules'
check 2 "rm -rf $T/web-42/src"
check 2 "rm -rf $T/web-42/.gradle"     # mobile artifact, not a web one
check 2 "rm -rf $T/web-42"
check 2 "rm -rf $T/web-42/node_modules $T/web-42/src"
grep -q 'playwright-report' "$T/err"; assert_eq 0 $? "block message lists web artifacts"

mkdir -p "$T/Projects/site/node_modules" "$T/Projects/site/src" "$T/.agent-workflow" "$T/Other/site/node_modules"
printf '# web roots\n%s\n' "$T/Projects" > "$T/.agent-workflow/build-roots.txt"
HOME=$T check 0 "rm -rf $T/Projects/site/node_modules"
HOME=$T check 2 "rm -rf $T/Projects/site/src"
HOME=$T check 2 "rm -rf $T/Other/site/node_modules"
HOME=$T check 2 "rm -rf $T/Projects"

# QA temp output: /tmp/qa and ${TMPDIR}/qa
check 0 'rm -rf /tmp/qa/PROJ-42'
check 2 'rm -rf /tmp/qa'
mkdir -p "$T/tmpdir"
TMPDIR="$T/tmpdir" check 0 "rm -rf $T/tmpdir/qa/PROJ-42/shots"
TMPDIR="$T/tmpdir" check 2 "rm -rf $T/tmpdir/other"
exit $FAILS
