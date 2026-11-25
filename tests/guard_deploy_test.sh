#!/usr/bin/env bash
# Deploys/publishes: allowed in normal mode (production = stop-and-ask rule, not guard),
# blocked in read-only audit mode except read verbs.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
G="$REPO/hooks/guard-frontend.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export AGENT_WORKFLOW_STATE="$T/st"
check() { # expected-exit audit(1|'') command
  local j got; j=$(jq -cn --arg c "$3" --arg d "$T" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}')
  got=$(AGENT_AUDIT=$2 bash -c 'printf "%s" "$1" | "$2" >/dev/null 2>&1; echo $?' _ "$j" "$G")
  assert_eq "$1" "$got" "[$1] ${2:+audit: }$3"
}
for c in 'vercel' 'vercel deploy' 'vercel --prod' 'vercel deploy --prod --yes' 'netlify deploy --prod' \
  'firebase deploy --only hosting' 'firebase hosting:channel:deploy pr-12' 'wrangler deploy' 'wrangler pages deploy dist' \
  'npm publish' 'pnpm publish --access public' 'yarn publish' 'npx vercel --prod' 'cd app && vercel --prod'; do
  check 0 '' "$c"
  check 2 1 "$c"
done
for c in 'vercel ls' 'vercel inspect https://x.vercel.app' 'vercel logs x' 'vercel whoami' 'vercel --version' \
  'netlify status' 'firebase hosting:channel:list' 'wrangler pages deployment list' \
  'npm run build' 'npm test' 'pnpm install' 'yarn playwright test' 'npx playwright test'; do
  check 0 1 "$c"
done
exit $FAILS
