#!/usr/bin/env bash
# hooks/guard-adapter.sh: payload hook tiap agen coding diterjemahkan ke bentuk guard-frontend.sh,
# dan penolakan dijawab dalam format agen itu (exit 2, atau JSON deny untuk Cursor).
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
A="$REPO/hooks/guard-adapter.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export AGENT_WORKFLOW_STATE="$T/st"; mkdir -p "$T/st"
W="$T/w"; git init -q "$W"; git -C "$W" remote add origin "$T/o.git"; git -C "$W" remote add upstream "$T/u.git"
P="git push upstream main"; OK="git status"
run() { # expected agent json
  local got; got=$(printf '%s' "$3" | bash "$A" "$2" >"$T/out" 2>"$T/err"; echo $?)
  assert_eq "$1" "$got" "[$1] $2 $3"
}
j() { jq -cn "$@"; }
run 2 claude "$(j --arg c "$P" --arg d "$W" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}')"
run 0 claude "$(j --arg c "$OK" --arg d "$W" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}')"
run 2 codex "$(j --arg c "$P" --arg d "$W" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$c},cwd:$d}')"
grep -q "DIBLOKIR oleh guard" "$T/err"; assert_eq 0 $? "codex: alasan di stderr"
run 0 codex "$(j --arg c "$OK" --arg d "$W" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}')"
run 2 gemini "$(j --arg c "$P" --arg d "$W" '{tool_name:"run_shell_command",tool_input:{command:$c},cwd:$d}')"
run 0 gemini "$(j --arg c "$OK" --arg d "$W" '{tool_name:"run_shell_command",tool_input:{command:$c},cwd:$d}')"
run 0 gemini "$(j --arg d "$W" '{tool_name:"read_file",tool_input:{file_path:"x"},cwd:$d}')"
run 2 copilot "$(j --arg c "$P" --arg d "$W" '{toolName:"bash",toolArgs:({command:$c}|tojson),cwd:$d}')"
run 2 copilot "$(j --arg c "$P" --arg d "$W" '{tool_name:"bash",tool_input:{command:$c},cwd:$d}')"
run 0 copilot "$(j --arg c "$OK" --arg d "$W" '{toolName:"bash",toolArgs:({command:$c}|tojson),cwd:$d}')"
run 0 cursor "$(j --arg c "$P" --arg d "$W" '{command:$c,cwd:$d}')"
assert_eq deny "$(jq -r .permission "$T/out")" "cursor: JSON permission deny"
run 0 cursor "$(j --arg c "$OK" --arg d "$W" '{command:$c,cwd:$d}')"
assert_eq "" "$(cat "$T/out")" "cursor: diizinkan tanpa output"
# edit di worktree primary (repo dengan worktree tambahan) lewat tool tulis agen lain
git -C "$W" -c user.email=a@b -c user.name=a commit -q --allow-empty -m init
git -C "$W" worktree add -q "$T/w-1" -b fix/X-1
run 2 gemini "$(j --arg f "$W/a.txt" --arg d "$W" '{tool_name:"write_file",tool_input:{file_path:$f,content:"x"},cwd:$d}')"
run 0 gemini "$(j --arg f "$T/w-1/a.txt" --arg d "$T/w-1" '{tool_name:"write_file",tool_input:{file_path:$f,content:"x"},cwd:$d}')"
run 2 copilot "$(j --arg f "$W/a.txt" --arg d "$W" '{toolName:"edit",toolArgs:({path:$f}|tojson),cwd:$d}')"
# masukan rusak diizinkan (sama seperti guard), agen tak dikenal tidak memblokir
run 0 gemini 'bukan json'
run 0 vim '{}'
echo "guard_adapter_test FAILS=$FAILS"; exit $FAILS
