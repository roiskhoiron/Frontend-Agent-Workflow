#!/usr/bin/env bash
# Atlassian connector names differ per machine (claude_ai_Atlassian, Atlassian, Atlassian_MCP):
# transition check and audit-mode write block must cover all of them, incl. the generic executors.
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
G="$REPO/hooks/guard-frontend.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/st"
echo '{"PROJ":{"allow":["21","31"],"names":{"21":"In Progress","31":"Ready To Review"}}}' > "$T/st/jira-transitions.json"
export AGENT_WORKFLOW_STATE="$T/st"
run() { # expected env tool input-json
  local j got; j=$(jq -cn --arg t "$3" --argjson i "$4" '{tool_name:$t,tool_input:$i,cwd:"/"}')
  got=$(env $2 bash -c 'printf "%s" "$1" | "$2" >/dev/null 2>&1; echo $?' _ "$j" "$G")
  assert_eq "$1" "$got" "[$1] ${2#AGENT_AUDIT=} $3 $4"
}
N=AGENT_AUDIT=; A=AGENT_AUDIT=1
for p in mcp__claude_ai_Atlassian mcp__Atlassian mcp__Atlassian_MCP; do
  run 0 $N ${p}__transitionJiraIssue '{"issueIdOrKey":"PROJ-1","transition":{"id":"31"}}'
  run 2 $N ${p}__transitionJiraIssue '{"issueIdOrKey":"PROJ-1","transition":{"id":"41"}}'
  run 0 $N ${p}__addCommentToJiraIssue '{"issueIdOrKey":"PROJ-1"}'
  for v in addCommentToJiraIssue createJiraIssue editJiraIssue transitionJiraIssue createConfluencePage updateConfluencePage; do
    run 2 $A ${p}__$v '{"issueIdOrKey":"PROJ-1"}'
  done
  run 0 $A ${p}__getJiraIssue '{"issueIdOrKey":"PROJ-1"}'
  run 0 $A ${p}__searchJiraIssuesUsingJql '{"jql":"x"}'
done
run 2 $N mcp__Atlassian__TransitionJiraIssue '{"issueIdOrKey":"PROJ-1","transition":{"id":"41"}}'   # verb case-insensitive
# generic executors (Atlassian_MCP): a transition through executeWrite is checked the same way
run 0 $N mcp__Atlassian_MCP__executeWrite '{"name":"transitionJiraIssue","cloudId":"c","inputs":{"issueIdOrKey":"PROJ-1","transition":{"id":"21"}}}'
run 2 $N mcp__Atlassian_MCP__executeWrite '{"name":"transitionJiraIssue","cloudId":"c","inputs":{"issueIdOrKey":"PROJ-1","transition":{"id":"41"}}}'
run 0 $N mcp__Atlassian_MCP__executeWrite '{"name":"addWorklog","cloudId":"c","inputs":{}}'
run 2 $A mcp__Atlassian_MCP__executeWrite '{"name":"addWorklog","cloudId":"c","inputs":{}}'
run 2 $A mcp__Atlassian_MCP__executeDestructive '{"name":"deleteIssue","cloudId":"c","inputs":{}}'
run 0 $A mcp__Atlassian_MCP__executeRead '{"name":"getIssue","cloudId":"c","inputs":{}}'
# GitHub MCP writes are audit-blocked too (guard_board_test.sh); unrelated MCP servers are not touched
run 2 $A mcp__github__create_pull_request '{}'
run 0 $A mcp__Claude_Docs__batch '{}'
exit $FAILS
