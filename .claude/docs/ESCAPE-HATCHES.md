# Escape Hatches — Everything That Will Fail
## CRITICAL: Hook Exit Codes
exit 1 = NON-BLOCKING. Use JSON + exit 0 or exit 2. All hooks trap ERR → fail closed.
## CRITICAL: Hooks Only Fire on Matching Tools
Bash redirects bypass Write hooks. PreToolUse:Bash scans for redirects.
## CRITICAL: Stop Hook Infinite Loop
Check stop_hook_active first. Exit immediately if true.
## HIGH: jq Not Installed
Every hook checks first. If missing, fail closed.
## HIGH: Stale JOURNAL.md
Conductor validates timestamp. Warns if >1h old.
## MEDIUM: Claude Modifies Tests
pre-write-guard blocks test files unless CLAUDE_TDD_PHASE=red.
## MEDIUM: Rate Limit Backoff
Exponential: 5min → 10min → 20min. After 3: stop.
