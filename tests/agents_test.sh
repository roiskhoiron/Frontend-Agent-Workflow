#!/usr/bin/env bash
# Agen: frontmatter (name, model, description, tools) dan semua rujukan ke dokumen bersama / skrip bin/ harus ada di repo.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"

# fm FILE KEY -> nilai KEY di blok frontmatter --- pertama (kosong bila tidak ada)
fm() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1&&index($0,k": ")==1{print substr($0,length(k)+3)}' "$1"; }

for pair in spv:opus planner:claude-fable-5-2 validator:opus reviewer:opus release:haiku coder:sonnet qa:sonnet auditor:opus analis:opus pdm:sonnet product-designer:sonnet contract-runner:sonnet hoe:opus eskalasi:claude-fable-5-2 pjm:sonnet; do
  n=${pair%%:*} m=${pair#*:} f="$REPO/agents/$n.md"
  assert_eq yes "$([ -f "$f" ] && echo yes || echo no)" "agents/$n.md ada"
  [ -f "$f" ] || continue
  assert_eq "$n" "$(fm "$f" name)" "$n: name"
  assert_eq "$m" "$(fm "$f" model)" "$n: model"
  assert_eq yes "$([ -n "$(fm "$f" description)" ] && echo yes || echo no)" "$n: description"
  tools=$(fm "$f" tools)
  case $n in
    coder|qa)
      assert_eq yes "$([ -n "$tools" ] && echo yes || echo no)" "$n: tools eksplisit"
      assert_eq no "$(printf '%s' "$tools" | grep -qE 'mcp__|Atlassian|Claude_Docs' && echo yes || echo no)" "$n: tanpa tool MCP" ;;
    *) assert_eq "" "$tools" "$n: mewarisi semua tool" ;;
  esac
done
assert_eq 15 "$(ls "$REPO"/agents/*.md | wc -l | tr -d ' ')" "tepat 15 agen"

# setiap rujukan dokumen bersama / skrip harus ada di repo
files=$(ls "$REPO"/agents/*.md "$REPO"/skills/*/*.md "$REPO"/templates/*.md 2>/dev/null)
for r in $(cat $files | grep -oE 'frontend-kit/skills/_shared/[A-Za-z0-9_-]+\.md' | sort -u); do
  assert_eq yes "$([ -f "$REPO/skills/_shared/${r##*/}" ] && echo yes || echo no)" "rujukan $r ada"
done
for r in $(cat $files | grep -oE 'FRONTEND_WORKFLOW_DIR/(bin|templates)/[A-Za-z0-9_.-]+' | sort -u); do
  assert_eq yes "$([ -f "$REPO/${r#FRONTEND_WORKFLOW_DIR/}" ] && echo yes || echo no)" "rujukan $r ada"
done
# nama dokumen bersama yang disebut tanpa path (mis. `browser.md`) juga harus ada
for r in $(cat $files | grep -oE '`(rules|board|design-input|browser|credentials|deploy-release|report-format|devices|build-release)\.md`' | tr -d '`' | sort -u); do
  assert_eq yes "$([ -f "$REPO/skills/_shared/$r" ] && echo yes || echo no)" "dokumen bersama $r ada"
done
for d in rules board design-input browser credentials deploy-release report-format; do
  assert_eq yes "$([ -f "$REPO/skills/_shared/$d.md" ] && echo yes || echo no)" "_shared/$d.md ada"
done
# netral agen coding: skill/agen tidak merujuk path khusus Claude Code (~/.claude/...)
assert_eq "" "$(grep -lE '~/\.claude/' $files 2>/dev/null)" "tanpa path ~/.claude/ di skill/agen"
# kit ini tidak boleh merujuk dokumen/variabel kit Mobile
assert_eq "" "$(grep -lE '_agent-workflow-shared|AGENT_WORKFLOW_DIR|device-pick|device-lock|build-number' $files 2>/dev/null)" "tanpa rujukan kit Mobile"
assert_eq yes "$([ -f "$REPO/templates/env.agent.local" ] && echo yes || echo no)" "template env ada"
# repo publik: tanpa path user atau kata privat (kata tambahan: .private-denylist yang di-gitignore)
assert_eq "" "$(grep -lE '/Users/|@gmail' $files "$REPO/templates/env.agent.local" 2>/dev/null)" "tanpa identitas privat"
if [ -f "$REPO/.private-denylist" ]; then
  assert_eq "" "$(git -C "$REPO" grep -lwFf <(grep -v '^[[:space:]]*$' "$REPO/.private-denylist") -- . ':!.private-denylist' 2>/dev/null)" "tanpa kata dari .private-denylist"
fi

echo "agents_test FAILS=$FAILS"; exit $FAILS
