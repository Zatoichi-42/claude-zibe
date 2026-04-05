#!/usr/bin/env bash
PROJ="${CLAUDE_PROJECT_DIR:-.}"
[ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_TDD_PHASE=" >> "$CLAUDE_ENV_FILE"
echo "=== Session Start ==="
echo "Project: $PROJ"
echo "Branch: $(cd "$PROJ" && git branch --show-current 2>/dev/null || echo 'n/a')"
echo "Modified: $(cd "$PROJ" && git diff --name-only 2>/dev/null | wc -l | tr -d ' ') files"
for h in "$HOME/.claude/hooks/"*.sh; do
  [ -f "$h" ] && [ ! -x "$h" ] && chmod +x "$h" 2>/dev/null && echo "Fixed: $h"
done
command -v jq &>/dev/null || echo "WARNING: jq not installed. Hooks will FAIL CLOSED."
find "$PROJ/.claude/logs/" -name "*.log" -mtime +7 -delete 2>/dev/null||true
if [ -f "$PROJ/.claude/JOURNAL.md" ]; then
  echo ""; echo "=== Previous Journal ==="; cat "$PROJ/.claude/JOURNAL.md"; echo "=== End ==="
fi
[ -f "$PROJ/.claude/ratchet-state.json" ] && command -v jq &>/dev/null && \
  echo "Ratchet: $(jq -r '"exp="+(.experiment_count|tostring)+" kept="+(.kept_improvements|length|tostring)' "$PROJ/.claude/ratchet-state.json" 2>/dev/null || echo '?')"
for f in "$PROJ/TODO.md" "$PROJ/.claude/TODO.md"; do
  [ -f "$f" ] && { echo "Tasks: $(grep -c '^\- \[ \]' "$f" 2>/dev/null || echo 0) remaining"; break; }
done
echo "====================="
exit 0
