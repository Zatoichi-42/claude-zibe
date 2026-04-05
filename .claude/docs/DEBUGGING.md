# Debugging Guide
## Hook Doesn't Block
exit 1 = NON-BLOCKING. Use JSON permissionDecision:"deny" + exit 0.
Test: `echo '{"tool_input":{"command":"rm -rf /"}}' | bash ~/.claude/hooks/pre-tool-security.sh`
## Stop Hook Loops
Check stop_hook_active FIRST.
## Claude Modifies Tests
pre-write-guard blocks unless CLAUDE_TDD_PHASE=red.
## Context Exhaustion
/compact at 50%. New session at 70%. /clear at 90%+.
## Recovery
`git checkout -- .` | `git reset --hard <hash>` | `chmod +x ~/.claude/hooks/*.sh` | `claude --debug "hooks"`
