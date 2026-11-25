#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
# fixture kit (independent of what skills/agents the real repo has right now)
mkfix() { # dir
  mkdir -p "$1/skills/_shared" "$1/skills/validate-tiket" "$1/skills/read-ticket" "$1/agents" "$1/hooks" "$1/templates" "$1/launchd"
  cp "$REPO/install.sh" "$1/"; cp "$REPO/launchd/"*.plist "$1/launchd/"
  echo '# rules' > "$1/skills/_shared/rules.md"; echo x > "$1/skills/validate-tiket/SKILL.md"; echo x > "$1/skills/read-ticket/SKILL.md"
  echo x > "$1/agents/spv.md"; printf '#!/bin/sh\nexit 0\n' > "$1/hooks/guard-frontend.sh"; chmod +x "$1/hooks/guard-frontend.sh"
  printf '# Frontend agent workflow\n- isi\n' > "$1/templates/claude-global.md"
}
K="$T/kit"; mkfix "$K"; K=$(cd "$K" && pwd -P)
H="$T/h1"; mkdir -p "$H/.claude"
MG='"/opt/mobile/hooks/guard.sh"'
jq -n --arg c "$MG" '{hooks:{PreToolUse:[{matcher:"Bash",hooks:[{type:"command",command:"rtk hook claude"}]},{matcher:"Bash|Edit",hooks:[{type:"command",command:$c}]}]}}' > "$H/.claude/settings.json"

assert_exit 0 "install run 1" -- bash "$K/install.sh" --home "$H"
assert_exit 0 "install run 2 (idempotent)" -- bash "$K/install.sh" --home "$H"
S="$H/.claude/settings.json"
assert_eq "$K/skills/validate-tiket" "$(readlink "$H/.claude/skills/validate-tiket")" "flow skill symlink"
assert_eq yes "$([ -L "$H/.claude/skills/read-ticket" ] && echo yes)" "internal skill symlink"
assert_eq "$K/skills/_shared" "$(readlink "$H/.claude/skills/_frontend-workflow-shared")" "shared symlink name"
assert_eq no "$([ -e "$H/.claude/skills/_shared" ] && echo yes || echo no)" "_shared not linked by own name"
assert_eq "$K/agents/spv.md" "$(readlink "$H/.claude/agents/spv.md")" "agent symlink"
assert_eq 1 "$(jq '[.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend.sh"))]|length' "$S")" "guard hook once"
assert_eq "\"$K/hooks/guard-frontend.sh\"" "$(jq -r '.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend"))|.hooks[0].command' "$S")" "guard path quoted"
assert_eq 'Bash|Edit|Write|MultiEdit|NotebookEdit|mcp__.*Atlassian.*__.*|mcp__.*[Gg]it[HhLl][a-z]*__.*' "$(jq -r '.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend"))|.matcher' "$S")" "guard matcher"
assert_eq 1 "$(jq '[.hooks.PreToolUse[]|select(.hooks[0].command=="rtk hook claude")]|length' "$S")" "other hook preserved"
assert_eq "Bash|Edit" "$(jq -r --arg c "$MG" '.hooks.PreToolUse[]|select(.hooks[0].command==$c)|.matcher' "$S")" "mobile guard.sh entry untouched"
assert_eq yes "$([ -f "$S.bak-frontend-workflow" ] && echo yes)" "backup made"
assert_eq 0 "$(jq '[.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend"))]|length' "$S.bak-frontend-workflow")" "backup = original"
assert_eq yes "$([ -d "$H/.agent-workflow/logs" ] && echo yes)" "logs dir"
assert_eq 1 "$(grep -c '^# Frontend agent workflow' "$H/.claude/CLAUDE.md")" "global CLAUDE.md appended once"
c=$(jq -r '.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend"))|.hooks[0].command' "$S")
assert_eq 0 "$(echo '{"tool_name":"Read"}' | sh -c "$c" >/dev/null 2>&1; echo $?)" "hook command runs via shell"

# conflicts with another kit (mobile): refuse, --force replaces symlinks only
H2="$T/h2"; mkdir -p "$H2/.claude/skills" "$H2/.claude/agents" "$T/mobile/skills/validate-tiket"
ln -s "$T/mobile/skills/validate-tiket" "$H2/.claude/skills/validate-tiket"
ln -s "$T/mobile/agents/spv.md" "$H2/.claude/agents/spv.md"
out=$(bash "$K/install.sh" --home "$H2" 2>&1); rc=$?
assert_eq 1 "$rc" "other kit's symlink -> refuse"
case "$out" in *validate-tiket*spv.md*--force*) r=ok;; *) r=no;; esac; assert_eq ok "$r" "conflicts listed + --force hint"
assert_eq "$T/mobile/skills/validate-tiket" "$(readlink "$H2/.claude/skills/validate-tiket")" "refuse: nothing replaced"
assert_eq no "$([ -e "$H2/.claude/skills/read-ticket" ] && echo yes || echo no)" "refuse: nothing linked"
assert_exit 0 "--force replaces other kit's symlinks" -- bash "$K/install.sh" --home "$H2" --force
assert_eq "$K/skills/validate-tiket" "$(readlink "$H2/.claude/skills/validate-tiket")" "--force: relinked"
H3="$T/h3"; mkdir -p "$H3/.claude/skills/validate-tiket"; echo mine > "$H3/.claude/skills/validate-tiket/SKILL.md"
assert_exit 1 "real dir conflict refused" -- bash "$K/install.sh" --home "$H3"
assert_exit 1 "real dir conflict refused even with --force" -- bash "$K/install.sh" --home "$H3" --force
assert_eq mine "$(cat "$H3/.claude/skills/validate-tiket/SKILL.md")" "real dir never deleted"
assert_exit 2 "unknown arg" -- bash "$K/install.sh" --bogus

# old guard-frontend entry with stale matcher/path upgraded in place
H4="$T/h4"; mkdir -p "$H4/.claude"
jq -n '{hooks:{PreToolUse:[{matcher:"Bash",hooks:[{type:"command",command:"\"/old/place/hooks/guard-frontend.sh\""}]}]}}' > "$H4/.claude/settings.json"
bash "$K/install.sh" --home "$H4" >/dev/null 2>&1
assert_eq 1 "$(jq '[.hooks.PreToolUse[]|select(.hooks[0].command|test("guard-frontend"))]|length' "$H4/.claude/settings.json")" "upgrade: guard once"
assert_eq "\"$K/hooks/guard-frontend.sh\"" "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' "$H4/.claude/settings.json")" "upgrade: path updated"

# repo path with a space
R="$T/my kit"; mkfix "$R"; H5="$T/h5"; mkdir -p "$H5"
assert_exit 0 "install from path with space" -- bash "$R/install.sh" --home "$H5"
c=$(jq -r '.hooks.PreToolUse[0].hooks[0].command' "$H5/.claude/settings.json")
assert_eq 0 "$(echo '{"tool_name":"Read"}' | sh -c "$c" >/dev/null 2>&1; echo $?)" "space path: hook runs via shell"
echo "install_test FAILS=$FAILS"; exit $FAILS
