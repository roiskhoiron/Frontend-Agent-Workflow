#!/bin/bash
# Usage: guard-adapter.sh <claude|codex|gemini|copilot|cursor>   (stdin = the agent's pre-tool hook JSON)
# Translates another coding agent's "before tool" hook payload into the Claude Code shape that
# guard-frontend.sh reads ({tool_name, tool_input:{command|file_path}, cwd, session_id}), runs the
# guard, and answers in the agent's own deny format:
#   claude, codex, gemini, copilot: exit 2 + reason on stderr (all four treat exit 2 as deny)
#   cursor (beforeShellExecution):  stdout {"permission":"deny","user_message","agent_message"}, exit 0
# Tool name mapping: shell tools -> Bash, file write/edit tools -> Write; everything else passes
# through unchanged (the guard allows unknown tools). Unparseable input is allowed, like the guard.
DIR="$(cd "$(dirname "$0")" && pwd -P)"
G="$DIR/guard-frontend.sh"
agent=${1:-claude}
PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
JQ=$(command -v jq) || { echo "DIBLOKIR oleh guard: jq tidak ditemukan." >&2; exit 2; }
input=$(cat)

case $agent in
  claude|codex) norm=$input ;;   # Codex PreToolUse uses the same shape (tool_name Bash, tool_input.command)
  gemini|copilot|cursor)
    norm=$(printf '%s' "$input" | "$JQ" -c --arg a "$agent" '
      def args: (.tool_input // .toolArgs // {}) | if type == "string" then (try fromjson catch {command: .}) else . end;
      def shell: {tool_name: "Bash", tool_input: {command: (args.command // args.cmd // "")}};
      def write: {tool_name: "Write", tool_input: {file_path: (args.file_path // args.absolute_path // args.path // args.filePath // "")}};
      (.tool_name // .toolName // "") as $t
      | (if $a == "cursor" then {tool_name: "Bash", tool_input: {command: (.command // "")}}
         elif ($t | test("^(run_shell_command|bash|shell|powershell|terminal|run_in_terminal)$"; "i")) then shell
         elif ($t | test("^(write_file|replace|edit|create|write|str_replace|edit_file|create_file|apply_patch)$"; "i")) then write
         else {tool_name: $t, tool_input: args} end)
      + {cwd: (.cwd // (.workspace_roots // [])[0] // ""), session_id: (.session_id // .sessionId // .conversation_id // "")}' 2>/dev/null) || exit 0 ;;
  *) echo "usage: guard-adapter.sh <claude|codex|gemini|copilot|cursor>" >&2; exit 0 ;;
esac

err=$(printf '%s' "$norm" | "$G" 2>&1 >/dev/null); rc=$?
[ "$rc" -eq 2 ] || exit 0
if [ "$agent" = cursor ]; then
  "$JQ" -cn --arg m "$err" '{permission: "deny", user_message: $m, agent_message: $m}'
  exit 0
fi
echo "$err" >&2
exit 2
