#!/usr/bin/env bash
INPUT=$(cat 2>/dev/null || echo '{}')
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
[ "$STOP_ACTIVE" = "true" ] && exit 0
PROJ="${CLAUDE_PROJECT_DIR:-.}"
TS=$(date +%Y-%m-%d\ %H:%M:%S)
BR=$(cd "$PROJ" && git branch --show-current 2>/dev/null || echo "unknown")
MC=$(cd "$PROJ" && git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
LC=$(cd "$PROJ" && git log --oneline -3 2>/dev/null || echo "none")
TEST="unknown"
if [ -f "$PROJ/package.json" ] && grep -q '"test"' "$PROJ/package.json" 2>/dev/null; then
  (cd "$PROJ" && timeout 30 npm run test -- --passWithNoTests --silent 2>/dev/null) && TEST="PASSING" || TEST="FAILING"
elif [ -f "$PROJ/pyproject.toml" ] || [ -f "$PROJ/pytest.ini" ]; then
  (cd "$PROJ" && timeout 30 python -m pytest --tb=no -q 2>/dev/null) && TEST="PASSING" || TEST="FAILING"
fi
TN=""
for f in "$PROJ/TODO.md" "$PROJ/.claude/TODO.md"; do
  [ -f "$f" ] && { TN=$(grep -m3 '^\- \[ \]' "$f" 2>/dev/null || echo "none"); break; }
done
mkdir -p "$PROJ/.claude" 2>/dev/null||true
cat > "$PROJ/.claude/JOURNAL.md" << J
# Journal — $TS
Branch: $BR | $MC uncommitted | Tests: $TEST
Commits: $LC
Next: $TN
Resume: read this, check git diff, run tests, continue.
J
cp "$PROJ/.claude/JOURNAL.md" "$PROJ/.claude/HANDOFF.md" 2>/dev/null||true
[ "$TEST" = "FAILING" ] && echo "Tests FAILING." >&2
exit 0
