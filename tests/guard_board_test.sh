#!/usr/bin/env bash
# Platform tiket umum (board.md): status hanya ke nilai di board-status.json, menutup issue = Done
# (diblokir), Jira tetap jalan lewat board-status.json maupun jira-transitions.json milik kit Mobile.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
G="$REPO/hooks/guard-frontend.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/st" "$T/none"
cat > "$T/st/board-status.json" <<'J'
{"WEB":{"platform":"github-project","project":"PVT_1","allow":["optTodo","optProg","optRev"],"names":{"optRev":"Ready To Review"}},
 "APP":{"platform":"gitlab-board","label_prefix":"status::","allow":["status::todo","status::in-progress","status::review"]},
 "SHOP":{"platform":"jira","allow":["21"]}}
J
echo '{"OLD":{"allow":["31"]}}' > "$T/st/jira-transitions.json"
bashj() { jq -cn --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c},cwd:"/"}'; }
chk() { # expected state-dir command [env]
  local got; got=$(env AGENT_WORKFLOW_STATE="$2" AGENT_AUDIT=${4:-} bash -c 'printf "%s" "$1" | "$2" >/dev/null 2>&1; echo $?' _ "$(bashj "$3")" "$G")
  assert_eq "$1" "$got" "[$1] ${4:+audit }$3"
}
mcp() { # expected state-dir tool input [audit]
  local j got; j=$(jq -cn --arg t "$3" --argjson i "$4" '{tool_name:$t,tool_input:$i,cwd:"/"}')
  got=$(env AGENT_WORKFLOW_STATE="$2" AGENT_AUDIT=${5:-} bash -c 'printf "%s" "$1" | "$2" >/dev/null 2>&1; echo $?' _ "$j" "$G")
  assert_eq "$1" "$got" "[$1] ${5:+audit }$3 $4"
}
S=$T/st; N=$T/none
# menutup issue = Done
chk 2 $S 'gh issue close 12'
chk 2 $S 'glab issue close 12'
chk 2 $S 'gh project item-delete 3 --id X'
# GitHub Projects: opsi status
chk 0 $S 'gh project item-edit --id I --project-id PVT_1 --field-id F --single-select-option-id optRev'
chk 2 $S 'gh project item-edit --id I --project-id PVT_1 --field-id F --single-select-option-id optDone'
chk 2 $S 'gh project item-edit --id I --project-id=PVT_9 --field-id F --single-select-option-id=optRev'
chk 0 $S 'gh project item-edit --id I --project-id PVT_1 --field-id F --text "catatan"'
chk 2 $N 'gh project item-edit --id I --project-id PVT_1 --field-id F --single-select-option-id optRev'
# label status (GitLab board / GitHub labels)
chk 0 $S 'glab issue update 5 --label status::review'
chk 2 $S 'glab issue update 5 --label status::done'
chk 2 $S 'glab issue update 5 -l bug,status::done'
chk 0 $S 'glab issue update 5 --label bug'
chk 2 $S 'gh issue edit 5 --add-label status::done'
chk 0 $S 'gh issue edit 5 --add-label status::in-progress'
chk 2 $N 'gh issue edit 5 --add-label status:done'
chk 0 $N 'gh issue edit 5 --add-label bug'
# baca & komentar tetap boleh; audit memblokir tulisan ke papan
chk 0 $S 'gh issue view 5 --comments'
chk 0 $S 'gh issue comment 5 --body-file x.md'
chk 2 $S 'gh issue comment 5 --body-file x.md' 1
chk 0 $S 'gh issue view 5' 1
chk 0 $S 'gh pr view 5' 1
chk 2 $S 'glab issue note 5 -m hi' 1
# MCP GitHub/GitLab
mcp 2 $S mcp__github__issue_write '{"method":"update","issue_number":5,"state":"closed"}'
mcp 0 $S mcp__github__issue_write '{"method":"update","issue_number":5,"labels":["status::review"]}'
mcp 0 $S mcp__github__add_issue_comment '{"issue_number":5}'
mcp 2 $S mcp__github__add_issue_comment '{"issue_number":5}' 1
mcp 0 $S mcp__github__issue_read '{"issue_number":5}' 1
mcp 2 $S mcp__claude_ai_GitLab__update_issue '{"state_event":"close"}'
# Jira: board-status.json, lalu jira-transitions.json (kit Mobile)
mcp 0 $S mcp__Atlassian__transitionJiraIssue '{"issueIdOrKey":"SHOP-1","transition":{"id":"21"}}'
mcp 2 $S mcp__Atlassian__transitionJiraIssue '{"issueIdOrKey":"SHOP-1","transition":{"id":"41"}}'
mcp 0 $S mcp__Atlassian__transitionJiraIssue '{"issueIdOrKey":"OLD-1","transition":{"id":"31"}}'
mcp 2 $S mcp__Atlassian__transitionJiraIssue '{"issueIdOrKey":"NEW-1","transition":{"id":"31"}}'
echo "guard_board_test FAILS=$FAILS"; exit $FAILS
