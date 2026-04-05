#!/usr/bin/env bash
trap 'echo "{\"decision\":\"block\",\"reason\":\"Write guard crashed — failing closed\"}" && exit 0' ERR
INPUT=$(cat)
FILE_PATH=""
if command -v jq &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
else
  echo '{"decision":"block","reason":"jq not installed."}'
  exit 0
fi
[ -z "$FILE_PATH" ] && exit 0
if echo "$FILE_PATH" | grep -qE 'package-lock\.json|yarn\.lock|pnpm-lock\.yaml|\.gen\.(ts|js)|\.generated\.'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Protected/generated file."}}'
  exit 0
fi
if [ "${CLAUDE_TDD_PHASE:-}" != "red" ]; then
  if echo "$FILE_PATH" | grep -qE '\.test\.|\.spec\.|__tests__/|/test/|/tests/'; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Test files protected during implementation. Fix source code instead.","additionalContext":"Tests are the SPEC. If the test is wrong, ASK the user."}}'
    exit 0
  fi
fi
exit 0
