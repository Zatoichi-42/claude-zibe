#!/usr/bin/env bash
trap 'echo "{\"decision\":\"block\",\"reason\":\"Security hook crashed — failing closed\"}" && exit 0' ERR
INPUT=$(cat)
COMMAND=""
if command -v jq &>/dev/null; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  echo '{"decision":"block","reason":"jq not installed. Required for hooks. brew install jq / apt install jq"}'
  exit 0
fi
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qiE 'git (add|commit)'; then
  if git diff --cached --name-only 2>/dev/null | grep -qE '\.(env|key|pem|p12)$|secrets|credentials'; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Staging sensitive files (.env/.key/.pem)."}}'
    exit 0
  fi
fi
if echo "$COMMAND" | grep -qE 'rm -rf [^.]|drop (database|table)|truncate|:(){ :|:& };:'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Destructive command."}}'
  exit 0
fi
if echo "$COMMAND" | grep -qE 'git push.*(-f|--force).*(main|master)'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Force push to main/master."}}'
  exit 0
fi
if echo "$COMMAND" | grep -qiE '(echo|printf|cat).*>.*\.(env|key|pem)'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Writing to sensitive file."}}'
  exit 0
fi
if echo "$COMMAND" | grep -qE '\bdd\s+.*of=/dev/|\bmkfs\b|\bfdisk\b|\bshred\b'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Catastrophic disk op."}}'
  exit 0
fi
exit 0
