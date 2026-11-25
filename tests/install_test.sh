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
  cp "$REPO/hooks/guard-adapter.sh" "$1/hooks/"
  printf '# Frontend agent workflow\n- isi\n' > "$1/templates/agent-instructions.md"
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
assert_eq "$K" "$(readlink "$H/.agent-workflow/frontend-kit")" "kit pointer ~/.agent-workflow/frontend-kit"
assert_eq no "$([ -e "$H/.claude/skills/_shared" ] && echo yes || echo no)" "_shared bukan skill"
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

# v1 link _frontend-workflow-shared dibersihkan
H6="$T/h6"; mkdir -p "$H6/.claude/skills"; ln -s "$K/skills/_shared" "$H6/.claude/skills/_frontend-workflow-shared"
bash "$K/install.sh" --home "$H6" >/dev/null 2>&1
assert_eq no "$([ -e "$H6/.claude/skills/_frontend-workflow-shared" ] && echo yes || echo no)" "link lama _frontend-workflow-shared dihapus"

# agen lain, scope global
H7="$T/h7"; mkdir -p "$H7"
assert_exit 0 "global: semua agen" -- bash "$K/install.sh" --home "$H7" --agent all --scope global
assert_eq "$K/skills/read-ticket" "$(readlink "$H7/.agents/skills/read-ticket")" "skill di ~/.agents/skills"
assert_eq 1 "$(jq '[.hooks.PreToolUse[]|select(.matcher=="Bash")]|length' "$H7/.codex/hooks.json")" "codex PreToolUse Bash"
assert_eq "\"$K/hooks/guard-adapter.sh\" codex" "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' "$H7/.codex/hooks.json")" "codex lewat adapter"
assert_eq "run_shell_command|write_file|replace" "$(jq -r '.hooks.BeforeTool[0].matcher' "$H7/.gemini/settings.json")" "gemini BeforeTool"
assert_eq 1 "$(jq '.version' "$H7/.copilot/hooks/frontend-workflow.json")" "copilot hook file"
assert_eq "\"$K/hooks/guard-adapter.sh\" copilot" "$(jq -r '.hooks.preToolUse[0].bash' "$H7/.copilot/hooks/frontend-workflow.json")" "copilot preToolUse"
assert_eq "\"$K/hooks/guard-adapter.sh\" cursor" "$(jq -r '.hooks.beforeShellExecution[0].command' "$H7/.cursor/hooks.json")" "cursor beforeShellExecution"
for f in .claude/CLAUDE.md .codex/AGENTS.md .gemini/GEMINI.md .config/opencode/AGENTS.md; do
  assert_eq 1 "$(grep -c '^# Frontend agent workflow' "$H7/$f")" "instruksi global $f"
done
bash "$K/install.sh" --home "$H7" --agent all --scope global >/dev/null 2>&1
assert_eq 1 "$(jq '.hooks.PreToolUse|length' "$H7/.codex/hooks.json")" "codex hook tidak dobel"
assert_eq 1 "$(jq '.hooks.BeforeTool|length' "$H7/.gemini/settings.json")" "gemini hook tidak dobel"
assert_eq 1 "$(jq '.hooks.beforeShellExecution|length' "$H7/.cursor/hooks.json")" "cursor hook tidak dobel"
assert_eq 1 "$(grep -c '^# Frontend agent workflow' "$H7/.codex/AGENTS.md")" "instruksi tidak dobel"
# hook lama milik user dipertahankan
H8="$T/h8"; mkdir -p "$H8/.gemini"; echo '{"hooks":{"BeforeTool":[{"matcher":"x","hooks":[{"type":"command","command":"mine"}]}]},"theme":"dark"}' > "$H8/.gemini/settings.json"
bash "$K/install.sh" --home "$H8" --agent gemini --yes >/dev/null 2>&1
assert_eq "2 dark" "$(jq -r '"\(.hooks.BeforeTool|length) \(.theme)"' "$H8/.gemini/settings.json")" "gemini: setelan user tetap"
assert_eq no "$([ -e "$H8/.claude" ] && echo yes || echo no)" "agen yang tidak dipilih tidak disentuh"

# scope project
P="$T/proj"; git init -q "$P"; mkdir -p "$P/.github"; echo '# tim' > "$P/AGENTS.md"; git -C "$P" add AGENTS.md; git -C "$P" -c user.email=a@b -c user.name=a commit -qm init
H9="$T/h9"; mkdir -p "$H9"
assert_exit 0 "project: codex,claude,copilot" -- bash "$K/install.sh" --home "$H9" --agent codex,claude,copilot --scope project --project "$P"
assert_eq "$K/skills/validate-tiket" "$(readlink "$P/.agents/skills/validate-tiket")" "project: .agents/skills"
assert_eq "$K/skills/validate-tiket" "$(readlink "$P/.claude/skills/validate-tiket")" "project: .claude/skills"
assert_eq yes "$([ -f "$P/.claude/settings.local.json" ] && echo yes)" "project claude: settings.local.json"
assert_eq yes "$([ -f "$P/.codex/hooks.json" ] && echo yes)" "project codex hooks"
assert_eq yes "$([ -f "$P/.github/hooks/frontend-workflow.json" ] && echo yes)" "project copilot hooks"
assert_eq no "$([ -e "$H9/.claude/skills" ] && echo yes || echo no)" "project: home tidak disentuh"
assert_eq "$K" "$(readlink "$H9/.agent-workflow/frontend-kit")" "project: kit pointer tetap dibuat"
assert_eq 1 "$(grep -c '^# Frontend agent workflow' "$P/AGENTS.md")" "project AGENTS.md diberi blok"
assert_eq "# tim" "$(head -1 "$P/AGENTS.md")" "isi AGENTS.md lama tetap"
assert_eq 1 "$(grep -c '^# Frontend agent workflow' "$P/CLAUDE.md")" "project CLAUDE.md diberi blok"
assert_eq "" "$(git -C "$P" status --porcelain --untracked-files=all | grep -E '\.agents/|\.claude/skills|\.codex/hooks|\.github/hooks|settings\.local' )" "link + config lokal tidak muncul di git status"
assert_eq yes "$(git -C "$P" status --porcelain | grep -q 'AGENTS.md' && echo yes)" "AGENTS.md tetap terlihat untuk di-commit"
assert_exit 2 "agen tidak dikenal" -- bash "$K/install.sh" --home "$H9" --agent vim --yes
assert_exit 2 "scope tidak dikenal" -- bash "$K/install.sh" --home "$H9" --scope semua --yes
assert_exit 2 "folder project tidak ada" -- bash "$K/install.sh" --home "$H9" --scope project --project "$T/tidak-ada" --yes
# interaktif (stdin terminal tidak tersedia di tes: pilihan lewat flag saja); tanpa flag non-terminal = claude global
H10="$T/h10"; mkdir -p "$H10"
bash "$K/install.sh" --home "$H10" </dev/null >/dev/null 2>&1
assert_eq yes "$([ -L "$H10/.claude/skills/read-ticket" ] && echo yes)" "default non-terminal: claude global"
echo "install_test FAILS=$FAILS"; exit $FAILS
