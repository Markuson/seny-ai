#!/usr/bin/env bash
# Seny guard: a PreToolUse hook that turns two promises into rules.
#   1. Nobody pushes. Not Claude, not a subagent. Pushing is the human's job.
#      Opt out: export SENY_ALLOW_PUSH=1 before starting Claude Code.
#   2. The seny:reviewer agent is read-only: no file tools, no mutating commands.
# Exit 2 blocks the tool call and shows the message to Claude. Exit 0 lets the
# normal permission flow decide. No jq or python needed: plain bash and grep.

input=$(cat)

field() { # first string value of a top-level-ish JSON key, escapes kept
  printf '%s' "$input" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"(\\\\.|[^\"\\\\])*\"" | head -n1 |
    sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//"
}

block() { echo "Seny guard: $1" >&2; exit 2; }

tool=$(field tool_name)
agent=$(field agent_type)
cmd=$(field command)

# Separators that can start a new command: start, ; & | ( and whitespace.
s='(^|[;&|(`[:space:]])'
gitcmd="${s}git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+"

# 1. Never push.
if [ "$tool" = "Bash" ] && [ "${SENY_ALLOW_PUSH:-0}" != "1" ]; then
  if printf '%s' "$cmd" | grep -qE "${gitcmd}push([[:space:]]|$)"; then
    block "git push is blocked. Seny never pushes: tell the user the branch is ready and let them push. (To allow it, the user starts Claude Code with SENY_ALLOW_PUSH=1.)"
  fi
fi

# 2. The reviewer is read-only.
case "$agent" in
  seny:reviewer|seny:*:reviewer) ;;
  *) exit 0 ;;
esac

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    block "the reviewer is read-only. Report the problem as a finding with file:line and a fix instead of changing the file." ;;
esac

if [ "$tool" = "Bash" ]; then
  # Drop harmless redirections before looking for writes to files.
  clean=$(printf '%s' "$cmd" | sed -E 's#[0-9]*>{1,2}[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9]##g')
  mutating="${s}(rm|rmdir|mv|cp|mkdir|touch|tee|chmod|chown|ln|truncate|dd|unlink)[[:space:]]"
  mutating="$mutating|${s}sed[[:space:]]+(-[a-zA-Z]*i|--in-place)"
  mutating="$mutating|${s}perl[[:space:]]+-[a-zA-Z]*i"
  mutating="$mutating|${gitcmd}(add|commit|checkout|switch|reset|restore|stash|clean|merge|rebase|cherry-pick|revert|apply|am|push|pull|fetch|tag|rm|mv|worktree|branch[[:space:]]+-[dDmMcC])([[:space:]]|$)"
  mutating="$mutating|${s}git[[:space:]].*--output"
  mutating="$mutating|${s}(pnpm|npm|yarn|bun)[[:space:]]+(add|install|i|ci|remove|rm|uninstall|un|update|up|upgrade|link|dedupe|prune|publish)([[:space:]]|$)"
  mutating="$mutating|>"
  if printf '%s' "$clean" | grep -qE "$mutating"; then
    block "the reviewer may only run read-only git commands (diff, log, show, status, blame) and the project's checks. This command could change files: use Read or Grep, or report it as a finding."
  fi
fi

exit 0
