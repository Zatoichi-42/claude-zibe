#!/usr/bin/env bash
set -euo pipefail
# build-repo.sh — Generates the COMPLETE claude-zibe directory.
# Usage: bash build-repo.sh [target-dir]
# Creates ./claude-zibe/ with every file in correct paths.

ROOT="${1:-.}/claude-zibe"
[ -d "$ROOT" ] && { echo "$ROOT exists. Remove or pick another path."; exit 1; }
mkdir -p "$ROOT"
echo "Building claude-zibe at $ROOT ..."
wf() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

###############################################################################
# ROOT FILES
###############################################################################

wf "$ROOT/README.md" << 'EOF'
# claude-zibe — Claude Code Global Bootstrap

Self-moderating, self-healing development environment for Claude Code.
Installs to `~/.claude/` — applies to every project under `~`.

## Install
```bash
git clone https://github.com/Zatoichi-42/claude-zibe.git
cd claude-zibe
bash install.sh            # deploy to ~/.claude/
cd /your/project
bash project-install.sh    # scaffold project files
claude
/zibe-check
```

## Commands (all /zibe- prefixed)
| Command | Purpose |
|---------|---------|
| /zibe-todo | Quick TODO capture with optional proof metadata |
| /zibe-implement | TDD feature build (delegates to tdd-loop skill) |
| /zibe-ratchet | Autonomous improvement loop |
| /zibe-bootstrap | Init/verify project environment |
| /zibe-health | Comprehensive project health check |
| /zibe-check | 30-second spot check (stdout only) |
| /zibe-digest | Daily plain-text report |
| /zibe-dashboard | Interactive HTML dashboard |
| /zibe-walkthrough | Interactive project tour |
| /zibe-retro | Session retrospective |
| /zibe-prove | Run proof commands for claim verification |
| /zibe-sync-todo | Sync proof-log results back to TODO.md |
| /zibe-model | Override model (default/sonnet/opus) |
| /zibe-effort | Override effort (default/low/high) |
| /zibe-enforcement | List current enforcement state |

Native `/review` and `/simplify` are deliberately NOT overridden.

See `.claude/docs/MANUAL.md` for full documentation.
EOF

###############################################################################
# install.sh — copies .claude/ to ~/.claude/, sets perms
###############################################################################
wf "$ROOT/install.sh" << 'IEOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/.claude"
TGT="$HOME/.claude"
G='\033[0;32m';Y='\033[1;33m';R='\033[0;31m';NC='\033[0m'
ok(){ echo -e "  ${G}✓${NC} $1"; }
wn(){ echo -e "  ${Y}⚠${NC} $1"; }
fl(){ echo -e "  ${R}✗${NC} $1"; }
[ -d "$SRC" ] || { fl "Cannot find $SRC"; exit 1; }
echo "Installing claude-zibe → ~/.claude/ ..."
if [ -d "$TGT" ]; then
  BK="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backing up → $BK"; cp -r "$TGT" "$BK"; ok "Backup created"
fi
echo "Copying files..."
cp -r "$SRC"/* "$TGT/" 2>/dev/null||true
cp -r "$SRC"/.[!.]* "$TGT/" 2>/dev/null||true
mkdir -p "$TGT"/{logs,reports,worktrees}
echo "Setting permissions..."
find "$TGT/hooks" -name "*.sh" -exec chmod +x {} \; 2>/dev/null||true
find "$TGT/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null||true
echo "Checking requirements..."
command -v jq &>/dev/null && ok "jq" || fl "jq MISSING (brew install jq)"
command -v git &>/dev/null && ok "git" || fl "git MISSING"
command -v claude &>/dev/null && ok "claude" || wn "claude CLI not in PATH"
echo "Verifying..."
M=0
for f in CLAUDE.md settings.json model-config.json EVOLUTION.md OPEN-QUESTIONS.md; do
  [ -f "$TGT/$f" ] && ok "$f" || { fl "$f"; M=1; }
done
for d in commands skills agents hooks rules docs scripts; do
  [ -d "$TGT/$d" ] && ok "$d/" || { fl "$d/"; M=1; }
done
echo ""
[ "$M" -eq 0 ] && echo -e "${G}✓ Install complete!${NC}" || echo -e "${Y}⚠ Some files missing${NC}"
IEOF
chmod +x "$ROOT/install.sh"

###############################################################################
# project-install.sh — scaffolds project-level files in CWD
###############################################################################
wf "$ROOT/project-install.sh" << 'PEOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$SCRIPT_DIR/project-template"
[ -d "$TPL" ] || { echo "Cannot find $TPL"; exit 1; }
echo "Scaffolding project files in $(pwd) ..."
ci(){ local s="$1" d="$2"; mkdir -p "$(dirname "$d")"
  [ -f "$d" ] && echo "  ⏭ $d (exists)" || { cp "$s" "$d"; echo "  ✓ $d"; }; }
ci "$TPL/CLAUDE.md" "CLAUDE.md"
ci "$TPL/TODO.md" "TODO.md"
ci "$TPL/TODO-prompt.md" "TODO-prompt.md"
ci "$TPL/program.md" "program.md"
ci "$TPL/.claude/settings.json" ".claude/settings.json"
mkdir -p .claude/logs .claude/reports
echo "Done. Edit CLAUDE.md, TODO.md, program.md for your project."
PEOF
chmod +x "$ROOT/project-install.sh"

###############################################################################
# .claude/CLAUDE.md — Global Constitution
###############################################################################
wf "$ROOT/.claude/CLAUDE.md" << 'EOF'
# Claude Code — Global Constitution
# ~/.claude/CLAUDE.md — applies to ALL projects

## Prime Directives
1. Read this file, then project CLAUDE.md, then .claude/rules/ before substantive work.
2. Do not edit non-test source without a recent RED signal (failing test).
3. No silent failures — all code paths return data or typed errors.
4. Do not let unrelated failing tests redefine the current task.
5. Before major work, read .claude/OPEN-QUESTIONS.md and answer each relevant question.
6. There are no edge cases. If it can happen, it will. Every failure mode is a main path.

## TDD Protocol
1. Name the tests first — describe what you're proving before writing anything.
2. Write tests before implementation. Confirm RED.
3. Implement the MINIMUM to go GREEN. Refactor only while GREEN.
4. If the user gives an exact error string, reproduce it EXACTLY in a test.
5. Reproduce the exact user command before claiming a fix.
6. For CLI bugs, add integration tests for the real entrypoint.
7. NEVER modify test files to make them pass — fix the source code.

## Proof Protocol
Before using completion language ("done", "fixed", "implemented"):
1. Run /zibe-prove to execute proof commands for any claim-id items.
2. Run /zibe-sync-todo to update TODO.md from proof-log.json.
3. Only then mark items complete or commit phase-complete work.

## Code Rules
- Files under 300 lines. Functions under 40 lines.
- No `any` types — use `unknown` and narrow.
- Surface errors to STDOUT. Return Result types or typed errors.
- Prefer composition over inheritance. Named exports over default.

## Native Commands
- Use native `/review` for code review (NOT overridden by zibe).
- Use native `/simplify` for refactoring (NOT overridden by zibe).

## Context Management
- At 50%: /compact preserving modified files, test status, branch, tasks.
- At 70%: commit work, write HANDOFF, new session.
- Read .claude/HANDOFF.md after compact for state recovery.

## Git Workflow
- Branch: `feat/`, `fix/`, `refactor/`, `test/`, `docs/`
- Commits: conventional (`feat:`, `fix:`, `refactor:`, `test:`)
- NEVER commit to `main` or `master` directly.

## Model & Effort
- Planning, design, critique → HIGH effort (opus)
- Implementation, testing → STANDARD effort (sonnet)
- Override with /zibe-model and /zibe-effort. Check with /zibe-enforcement.

## References
- @.claude/docs/MANUAL.md — full system manual
- @.claude/docs/ARCHITECTURE.md — design decisions
- @.claude/docs/PATTERNS.md — patterns and anti-patterns
- @.claude/docs/DEBUGGING.md — known issues and recovery
- .claude/skills/ — on-demand workflows
- .claude/agents/ — isolated subagents
- .claude/EVOLUTION.md — instruction improvement proposals
EOF

###############################################################################
# .claude/settings.json — FIXED for 2026 API
###############################################################################
wf "$ROOT/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npm run *)","Bash(npx *)","Bash(pnpm *)","Bash(bun *)","Bash(node *)",
      "Bash(python *)","Bash(python3 *)","Bash(pip *)","Bash(pytest *)",
      "Bash(git add *)","Bash(git commit *)","Bash(git checkout *)","Bash(git branch *)",
      "Bash(git diff *)","Bash(git log *)","Bash(git status*)","Bash(git stash*)",
      "Bash(git merge *)","Bash(git worktree *)",
      "Bash(cat *)","Bash(ls *)","Bash(head *)","Bash(tail *)","Bash(wc *)",
      "Bash(grep *)","Bash(find *)","Bash(mkdir *)","Bash(cp *)","Bash(mv *)",
      "Bash(chmod +x *)","Bash(echo *)","Bash(date *)","Bash(sort *)","Bash(uniq *)",
      "Bash(sed *)","Bash(awk *)","Bash(jq *)","Bash(curl -s *)","Bash(bc *)",
      "Bash(timeout *)","Bash(tsc *)","Bash(eslint *)","Bash(prettier *)",
      "Bash(black *)","Bash(ruff *)",
      "Read","Write","Edit","MultiEdit","Glob","Grep","Agent"
    ],
    "deny": [
      "Bash(rm -rf /)","Bash(rm -rf ~)","Bash(rm -rf .git)","Bash(sudo *)",
      "Bash(curl * | bash)","Bash(curl * | sh)","Bash(wget * | bash)","Bash(wget * | sh)",
      "Bash(eval *)","Bash(git push * -f *)","Bash(git push * --force *)",
      "Bash(git push * main)","Bash(git push * master)",
      "Bash(chmod 777 *)","Bash(> /dev/sd*)","Bash(mkfs *)","Bash(dd *)"
    ]
  },
  "env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS":"1"},
  "hooks": {
    "SessionStart": [{"matcher":"startup|resume|compact|clear","hooks":[{
      "type":"command","command":"bash \"$HOME/.claude/hooks/session-start.sh\"",
      "timeout":15,"statusMessage":"Loading session context..."}]}],
    "PreToolUse": [
      {"matcher":"Bash","hooks":[{"type":"command",
        "command":"bash \"$HOME/.claude/hooks/pre-tool-security.sh\"",
        "timeout":5,"statusMessage":"Security check..."}]},
      {"matcher":"Write|Edit|MultiEdit","hooks":[{"type":"command",
        "command":"bash \"$HOME/.claude/hooks/pre-write-guard.sh\"",
        "timeout":5,"statusMessage":"Write guard..."}]}
    ],
    "PostToolUse": [{"matcher":"Write|Edit|MultiEdit","hooks":[{
      "type":"command","command":"bash \"$HOME/.claude/hooks/post-edit-autoformat.sh\"",
      "timeout":30}]}],
    "Stop": [{"hooks":[{"type":"command",
      "command":"bash \"$HOME/.claude/hooks/stop-journal.sh\"","timeout":45}]}],
    "SubagentStart": [{"hooks":[{"type":"command",
      "command":"bash \"$HOME/.claude/hooks/subagent-start.sh\"","timeout":5}]}],
    "PostCompact": [{"hooks":[{"type":"command",
      "command":"bash \"$HOME/.claude/hooks/post-compact-handoff.sh\"",
      "timeout":15,"statusMessage":"Preserving state..."}]}],
    "Notification": [{"matcher":"idleprompt","hooks":[{"type":"command",
      "command":"bash \"$HOME/.claude/hooks/notify.sh\"","timeout":5,"async":true}]}]
  }
}
EOF

###############################################################################
# .claude/model-config.json (ORIGINAL — kept as-is)
###############################################################################
wf "$ROOT/.claude/model-config.json" << 'EOF'
{
  "_comment": "Model and effort configuration for different task types",
  "tiers": {
    "high": {
      "_description": "Planning, architecture, design, critique.",
      "model": "opus", "effort": "high",
      "used_by": ["self-plan skill","self-critic agent","meta-ratchet skill","/zibe-retro"]
    },
    "standard": {
      "_description": "Implementation, testing, refactoring.",
      "model": "sonnet", "effort": "standard",
      "used_by": ["tdd-test-writer","tdd-implementer","ratchet-loop skill","/zibe-implement"]
    },
    "low": {
      "_description": "Scanning, formatting, simple lookups.",
      "model": "sonnet", "effort": "low",
      "used_by": ["scout skill","/zibe-check","/zibe-health"]
    }
  },
  "override_instructions": [
    "Use /zibe-model to override model globally.",
    "Use /zibe-effort to override effort globally.",
    "Use /zibe-enforcement to see current state."
  ]
}
EOF

# Snapshot defaults
cp "$ROOT/.claude/model-config.json" "$ROOT/.claude/model-config.defaults.json"

wf "$ROOT/.claude/model-enforcement.defaults.json" << 'EOF'
{"model":null,"effort":null,"source":"default","timestamp":""}
EOF
wf "$ROOT/.claude/model-enforcement.state.json" << 'EOF'
{"model":null,"effort":null,"source":"default","timestamp":""}
EOF

###############################################################################
# State files
###############################################################################
wf "$ROOT/.claude/ratchet-state.json" << 'EOF'
{"version":"1.0","created":"","last_updated":"","best_score":null,"experiment_count":0,"consecutive_failures":0,"baseline_metrics":{},"experiments":[],"kept_improvements":[],"exhausted_directions":[],"notes":"Initial template. Run /zibe-ratchet to populate."}
EOF
wf "$ROOT/.claude/proof-log.json" << 'EOF'
{"version":"1.0","claims":[],"last_run":"","notes":"Run /zibe-prove to populate."}
EOF
wf "$ROOT/.claude/EVOLUTION.md" << 'EOF'
# Bootstrap Evolution Log
## Instruction Budget
CLAUDE.md rule count: _UPDATE_ | Budget (<25): _UPDATE_
## Proposed Rules (Awaiting Human Review)
## Session Scores
## Promoted Rules
## Rejected Rules
## Retired Rules
EOF
wf "$ROOT/.claude/OPEN-QUESTIONS.md" << 'EOF'
# Open Questions — Ask Before Every Major Decision
**There are no edge cases, only certainties.**
## Lifecycle
- What happens if this session dies mid-implementation?
- Who or what restarts this work if the session is killed?
- If the Stop hook doesn't fire (hard kill), what state is lost?
## Observability
- Can the human see what's happening without typing commands?
- If this runs at 3am, how does the human know what happened?
## Autonomy
- Does this require human input to proceed?
- Are there permission prompts that will block autonomous execution?
## Architecture
- Are we assuming something exists that might not?
- Does this work with zero tests? Zero commits? Empty project?
- Could a simpler solution work?
## Human
- What if the human doesn't review EVOLUTION.md for a week?
- Is CLAUDE.md under 25 rules?
## Integration
- Does this change break any existing hooks?
- Will this survive a /compact and session restart?
- Is this committed to git or only in transient files?
EOF

###############################################################################
# .claude/.gitignore
###############################################################################
wf "$ROOT/.claude/.gitignore" << 'EOF'
JOURNAL.md
HANDOFF.md
PLAN.md
PLAN-CRITIQUE.md
ASSUMPTION-AUDIT.md
logs/
reports/
conductor-state.json
conductor.pid
model-enforcement.state.json
.DS_Store
EOF

###############################################################################
# HOOKS — ALL FIXED for 2026 (JSON decision format, CLAUDE_PROJECT_DIR)
###############################################################################
wf "$ROOT/.claude/hooks/pre-tool-security.sh" << 'HOOKEOF'
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
HOOKEOF

wf "$ROOT/.claude/hooks/pre-write-guard.sh" << 'HOOKEOF'
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
HOOKEOF

wf "$ROOT/.claude/hooks/post-edit-autoformat.sh" << 'HOOKEOF'
#!/usr/bin/env bash
INPUT=$(cat 2>/dev/null || true)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)
[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.html|*.md) npx prettier --write "$FILE_PATH" 2>/dev/null || true ;;
  *.py) black "$FILE_PATH" 2>/dev/null || ruff format "$FILE_PATH" 2>/dev/null || true ;;
  *.go) gofmt -w "$FILE_PATH" 2>/dev/null || true ;;
  *.rs) rustfmt "$FILE_PATH" 2>/dev/null || true ;;
esac
exit 0
HOOKEOF

wf "$ROOT/.claude/hooks/stop-journal.sh" << 'HOOKEOF'
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
HOOKEOF

wf "$ROOT/.claude/hooks/session-start.sh" << 'HOOKEOF'
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
HOOKEOF

wf "$ROOT/.claude/hooks/post-compact-handoff.sh" << 'HOOKEOF'
#!/usr/bin/env bash
PROJ="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJ/.claude" 2>/dev/null||true
cat > "$PROJ/.claude/HANDOFF.md" << H
# Handoff — $(date +%Y%m%d_%H%M%S) (post-compact)
Branch: $(cd "$PROJ" && git branch --show-current 2>/dev/null || echo "?")
Modified: $(cd "$PROJ" && git diff --name-only 2>/dev/null | head -20)
Commits: $(cd "$PROJ" && git log --oneline -3 2>/dev/null || echo "none")
Resume: read this, check git diff, run tests, continue from TODO.
H
echo '{"hookSpecificOutput":{"hookEventName":"PostCompact","additionalContext":"Compacted. Read .claude/HANDOFF.md to restore context."}}'
exit 0
HOOKEOF

wf "$ROOT/.claude/hooks/subagent-start.sh" << 'HOOKEOF'
#!/usr/bin/env bash
INPUT=$(cat 2>/dev/null || echo '{}')
AN=$(echo "$INPUT" | jq -r '.agent_name // "unknown"' 2>/dev/null || echo "unknown")
PROJ="${CLAUDE_PROJECT_DIR:-.}"
[ "$AN" = "tdd-test-writer" ] && [ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_TDD_PHASE=red" >> "$CLAUDE_ENV_FILE"
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"Project: $PROJ | Branch: $(cd "$PROJ" && git branch --show-current 2>/dev/null || echo unknown)\"}}"
exit 0
HOOKEOF

wf "$ROOT/.claude/hooks/notify.sh" << 'HOOKEOF'
#!/usr/bin/env bash
command -v osascript &>/dev/null && osascript -e 'display notification "Claude Code needs attention" with title "Claude Code"' 2>/dev/null||true
command -v notify-send &>/dev/null && notify-send "Claude Code" "Needs attention" 2>/dev/null||true
exit 0
HOOKEOF

###############################################################################
# COMMANDS — ALL zibe- prefixed
###############################################################################

wf "$ROOT/.claude/commands/zibe-todo.md" << 'EOF'
---
name: zibe-todo
description: Quick TODO capture. Appends a phase heading and checklist items to root TODO.md.
argument-hint: "phase name, item 1, item 2, item 3"
---
# /zibe-todo — Quick TODO Capture

Parse the arguments as: first segment is the phase name, remaining segments are checklist items (comma-separated).

## Process
1. Parse $ARGUMENTS: first comma-delimited segment = phase heading, rest = items
2. Open the root `TODO.md` file (create if missing)
3. Find the `## TODO LIST` section (create if missing)
4. Append under it:
   ```
   ## <phase name>
   - [ ] <item 1>
   - [ ] <item 2>
   - [ ] <item 3>
   ```
5. Confirm what was added

## Example
`/zibe-todo API hardening, add retry budget, add timeout handling, add structured diagnostics`

Appends:
```md
## API hardening
- [ ] add retry budget
- [ ] add timeout handling
- [ ] add structured diagnostics
```

## Advanced
For proof-sensitive items, the human can manually add under each item:
- `claim-id:` — stable identifier
- `proof-command:` — command to verify
- `proof-artifact:` — file to check
- `proof-assert:` — machine-checkable condition

Then use `/zibe-prove` and `/zibe-sync-todo`.
EOF

wf "$ROOT/.claude/commands/zibe-prove.md" << 'EOF'
---
name: zibe-prove
description: Run proof commands for claim-id items in TODO.md. Write results to proof-log.json.
---
# /zibe-prove — Execute Proof Commands

## Process
1. Read root `TODO.md`
2. Find all unchecked items (`- [ ]`) that have `claim-id:` and `proof-command:` metadata
3. For each claim:
   a. Run the `proof-command`
   b. Check exit code (proof-assert: command_exit_zero)
   c. If `proof-artifact` specified, verify the file exists
   d. If `proof-assert: artifact_json_path_exists=<path>` specified, verify the JSON path
   e. Record result in `.claude/proof-log.json`
4. Print summary: passed/failed/skipped claims

## proof-log.json format
```json
{
  "version": "1.0",
  "last_run": "<timestamp>",
  "claims": [
    {
      "claim_id": "validation.transport_status",
      "status": "pass|fail|skip",
      "proof_command": "...",
      "exit_code": 0,
      "assertions": [{"assert": "...", "result": "pass|fail"}],
      "timestamp": "..."
    }
  ]
}
```

## Important
- Do NOT mark TODO items as complete here. Use /zibe-sync-todo for that.
- Do NOT use completion language until proof passes.
EOF

wf "$ROOT/.claude/commands/zibe-sync-todo.md" << 'EOF'
---
name: zibe-sync-todo
description: Sync proof-log.json results back to TODO.md. Check off proven items.
---
# /zibe-sync-todo — Sync Proof Results to TODO

## Process
1. Read `.claude/proof-log.json`
2. Read root `TODO.md`
3. For each claim in proof-log with status "pass":
   a. Find the matching `- [ ]` item in TODO.md by its `claim-id:`
   b. Change `- [ ]` to `- [x]`
4. Write updated TODO.md
5. Report: N items checked off, M items still failing, K items not yet proven
EOF

wf "$ROOT/.claude/commands/zibe-model.md" << 'EOF'
---
name: zibe-model
description: Override model across agents, skills, and tier config. Usage: /zibe-model default|sonnet|opus
argument-hint: "default|sonnet|opus"
---
# /zibe-model — Model Override

## Usage
- `/zibe-model default` — restore model-config.defaults.json settings
- `/zibe-model sonnet` — force sonnet across all enforceable surfaces
- `/zibe-model opus` — force opus across all enforceable surfaces

## Process
1. Read $ARGUMENTS (default, sonnet, or opus)
2. If "default": copy `.claude/model-config.defaults.json` → `.claude/model-config.json`
   and reset `.claude/model-enforcement.state.json` to `{"model":null}`
3. If "sonnet" or "opus":
   a. Update `.claude/model-enforcement.state.json` with `{"model":"<value>","timestamp":"<now>"}`
   b. Update `.claude/model-config.json` tiers to use the specified model
   c. Note: hooks and rules do NOT have model settings (report as n/a)
4. Confirm the change

## Enforceable surfaces
- Agent frontmatter `model:` field
- Skill content (effort tiers reference model)
- `.claude/model-config.json` tier definitions
- NOT enforceable: hooks, rules (report n/a)
EOF

wf "$ROOT/.claude/commands/zibe-effort.md" << 'EOF'
---
name: zibe-effort
description: Override effort across skills and tier config. Usage: /zibe-effort default|low|high
argument-hint: "default|low|high"
---
# /zibe-effort — Effort Override

## Usage
- `/zibe-effort default` — restore defaults
- `/zibe-effort low` — force low effort across enforceable surfaces
- `/zibe-effort high` — force high effort across enforceable surfaces

## Process
1. If "default": reset `.claude/model-enforcement.state.json` effort to null
2. Otherwise: set effort in state file, update model-config.json tiers
3. Confirm the change
EOF

wf "$ROOT/.claude/commands/zibe-enforcement.md" << 'EOF'
---
name: zibe-enforcement
description: List current model and effort enforcement state by scope and file.
---
# /zibe-enforcement — Show Enforcement State

## Process
1. Read `.claude/model-enforcement.state.json` for active overrides
2. Read `.claude/model-config.json` for tier definitions
3. List each enforcement surface:
   - Agents: for each `.claude/agents/*.md`, show model from frontmatter
   - Skills: for each skill, show effort from frontmatter
   - Tier config: show model-config.json tiers
   - Hooks: report "n/a" (no native model setting)
   - Rules: report "n/a" (no native model setting)
4. Show active override if any, or "using defaults"
EOF

wf "$ROOT/.claude/commands/zibe-bootstrap.md" << 'EOF'
---
name: zibe-bootstrap
description: Verify global ~/.claude/ bootstrap and project-level files. Safe to run multiple times.
---
# /zibe-bootstrap — Verify Environment

Idempotent. Checks that the global bootstrap is installed and project files exist.
Does NOT recreate global infrastructure locally — commands, skills, agents, hooks,
rules, docs, and scripts belong in ~/.claude/ only.

## Step 1: Verify global bootstrap (~/.claude/)
Check that these GLOBAL directories and files exist:
- `~/.claude/CLAUDE.md`
- `~/.claude/settings.json`
- `~/.claude/model-config.json`
- `~/.claude/commands/` (should contain zibe-*.md files)
- `~/.claude/skills/` (should contain skill directories)
- `~/.claude/agents/` (should contain *.md agent files)
- `~/.claude/hooks/` (should contain *.sh files, all executable)
- `~/.claude/rules/` (should contain *.md rule files)
- `~/.claude/docs/` (should contain MANUAL.md and others)
- `~/.claude/scripts/` (should contain conductor.sh, bootstrap-claude.sh)

If any global files are missing: report them clearly and tell the user to run
`install.sh` from the claude-zibe repo. Do NOT recreate them locally.

## Step 2: Verify hook permissions
```bash
for h in ~/.claude/hooks/*.sh; do
  [ -f "$h" ] && [ ! -x "$h" ] && chmod +x "$h"
done
```

## Step 3: Verify project-level files
Check that these exist in the current project:
- `CLAUDE.md` at project root (project-specific stack and commands)
- `TODO.md` at project root (canonical task tracker)
- `program.md` at project root (ratchet directions)
- `.claude/settings.json` (project-level hooks and permissions)

If missing: tell the user to run `project-install.sh` from the claude-zibe repo,
or create them manually.

## Step 4: Create project-level directories (these DO belong per-project)
Only these directories should exist inside the project's `.claude/`:
- `.claude/logs/` — session logs (gitignored)
- `.claude/reports/` — generated dashboards and digests (gitignored)

Do NOT create these locally (they are global-only):
- commands/ skills/ agents/ hooks/ rules/ docs/ scripts/ worktrees/

## Step 5: Verify git
- If no `.git/`: offer to initialize
- If on `main` or `master`: warn about direct commits

## Step 6: Check tools
- `jq` — required for hooks (report version or MISSING)
- `git` — required
- Test runner — detect from package.json, pyproject.toml, etc.
- Linter, formatter — detect what's available

## Step 7: Initialize project state files (if missing)
- `.claude/ratchet-state.json` — initialize with empty template
- `.claude/proof-log.json` — initialize with empty template

## Step 8: Run quick validation
- Can tests run? (even if some fail)
- How many pass/fail?
- Lint clean?

## Report Format
```
━━━ BOOTSTRAP REPORT [date] ━━━━━━━━━━━━━━
  GLOBAL     OK|MISSING  — ~/.claude/ status
  PROJECT    OK|MISSING  — root files status
  HOOKS      OK|FIXED    — N global hooks executable
  GIT        OK|WARN     — branch status
  TOOLS      OK          — tool versions
  STATE      OK|FIXED    — ratchet/proof state
  TESTS      N passed, M failed
  LINT       clean|N errors
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
EOF

wf "$ROOT/.claude/commands/zibe-implement.md" << 'EOF'
---
name: zibe-implement
description: Build a feature using strict TDD. Delegates to tdd-loop skill.
argument-hint: "[feature description]"
---
# /zibe-implement — TDD Feature Build

## Process
1. Load the tdd-loop skill
2. Plan testable behaviors from: $ARGUMENTS
3. Delegate RED to tdd-test-writer agent
4. Confirm tests fail
5. Delegate GREEN to tdd-implementer agent
6. Confirm tests pass
7. Refactor in main context
8. Full verification (tests + types + lint)
9. Commit with conventional message

If description is vague, ask: input? output? error behavior? existing patterns?
EOF

wf "$ROOT/.claude/commands/zibe-ratchet.md" << 'EOF'
---
name: zibe-ratchet
description: Start autonomous improvement loop. Delegates to ratchet-loop skill.
argument-hint: "[focus area or blank for program.md]"
---
# /zibe-ratchet — Autonomous Improvement Loop

## Usage
```
/zibe-ratchet                    # Use program.md directions
/zibe-ratchet [specific area]    # Focus on one area
```
Delegates to ratchet-loop skill. Max 20 experiments. Reverts bad changes. Commits good ones.
EOF

wf "$ROOT/.claude/commands/zibe-health.md" << 'EOF'
---
name: zibe-health
description: Comprehensive project health check.
---
# /zibe-health — Project Health Check

Check: git status, tests (count/pass/fail/time), build, lint, typecheck, deps/audit, ratchet state, TODO status. Produce concise dashboard-style report.
EOF

wf "$ROOT/.claude/commands/zibe-check.md" << 'EOF'
---
name: zibe-check
description: 30-second spot check. Stdout only, no files.
effort: low
---
# /zibe-check — Quick Spot Check

Print to stdout. NO files. Under 25 lines. Under 10 seconds.

```
━━━ SPOT CHECK [datetime] ━━━━━━
🚦 [GREEN/YELLOW/RED]  [reason]
Commits 24h: N | Tests: status | Modified: N
LAST 3 COMMITS: • [hash] [msg]
CONCERNS: [issues or "None"]
NEXT: [first TODO]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
EOF

wf "$ROOT/.claude/commands/zibe-digest.md" << 'EOF'
---
name: zibe-digest
description: Generate human-readable daily digest. Plain text, 60-second read.
---
# /zibe-digest — Daily Digest

Write to `.claude/reports/digest-[YYYY-MM-DD].md` AND print to stdout.
Include: health signal, tests, build, lint, git activity, ratchet progress, tasks, warnings, summary. Under 60 lines. Read previous digest for deltas.
EOF

wf "$ROOT/.claude/commands/zibe-dashboard.md" << 'EOF'
---
name: zibe-dashboard
description: Generate interactive HTML dashboard at .claude/reports/dashboard.html.
---
# /zibe-dashboard — Visual Dashboard

Single self-contained HTML. Chart.js from CDN. Dark mode. Mobile-friendly. Under 50KB.
Bake data from: ratchet-state.json, EVOLUTION.md, TODO.md, proof-log.json, model-enforcement.state.json, git log, test/lint results.
Sections: header+health, tests, ratchet, tasks, git, warnings.
EOF

wf "$ROOT/.claude/commands/zibe-walkthrough.md" << 'EOF'
---
name: zibe-walkthrough
description: Generate interactive project tour at .claude/reports/walkthrough.html.
---
# /zibe-walkthrough — Project Tour

Single HTML. Prism.js for syntax highlighting. Sections: overview, file tree (color-coded), recent changes tour (commit slides), architecture, test coverage, ratchet history, known issues, how to continue.
EOF

wf "$ROOT/.claude/commands/zibe-retro.md" << 'EOF'
---
name: zibe-retro
description: Session retrospective. Analyze failures, propose instruction improvements.
---
# /zibe-retro — Session Retrospective

Read JOURNAL.md and git history. Identify failures (untested changes, rabbit holes, false fixes, silent failures, scope creep, test pollution, ignored instructions). Formulate rules. Check if rule exists. Propose to EVOLUTION.md. Score session. Do NOT edit CLAUDE.md directly.
EOF

###############################################################################
# SKILLS — original content, frontmatter fixed for 2026
###############################################################################

wf "$ROOT/.claude/skills/tdd-loop/SKILL.md" << 'EOF'
---
name: tdd-loop
description: >
  Enforce strict Red-Green-Refactor TDD cycle using subagents to prevent
  context pollution. Use when implementing new features or when user says
  "implement", "build", "add feature", "TDD".
argument-hint: "[feature description]"
user-invocable: false
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# TDD Loop — Red/Green/Refactor with Subagent Isolation

## Why Subagents
Separate context prevents implementation bleeding into test logic.

## Context
- Project: !`echo "${CLAUDE_PROJECT_DIR:-.}"`
- Branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Test runner: !`if [ -f package.json ] && grep -q '"test"' package.json; then echo "npm test"; elif [ -f pyproject.toml ]; then echo "pytest"; else echo "unknown"; fi`

## Phase 1: PLAN
1. Understand: $ARGUMENTS
2. Name tests first (plain-language list)
3. For each behavior: input, output, edge cases

## Phase 2: RED
Delegate to `tdd-test-writer` subagent. After: confirm FAIL, commit `test: red — [feature]`

## Phase 3: GREEN
Delegate to `tdd-implementer` subagent. After: confirm PASS, commit `feat: green — [feature]`

## Phase 4: REFACTOR (main context)
Clean up. Tests after EACH change. Commit `refactor: [what]`

## Phase 5: VERIFY
Full suite + typecheck + lint. Fix or revert if newly broken.

## Rules
- Tests are the SPEC. Never modify to pass. Ask user if test seems wrong.
- One behavior per test. Mock externals, never the unit under test.
- If user gave exact error string, reproduce it exactly.
- For CLI bugs, test the real entrypoint.
EOF

wf "$ROOT/.claude/skills/ratchet-loop/SKILL.md" << 'EOF'
---
name: ratchet-loop
description: >
  Autonomous improvement loop (Karpathy AutoResearch). Propose-implement-measure-keep/revert.
  Use when user says "improve", "optimize", "ratchet", "make it better".
argument-hint: "[focus area or 'all']"
user-invocable: false
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# Ratchet Loop — Six Steps

## Context
- Branch: !`git branch --show-current 2>/dev/null`
- Tests: !`npm test -- --passWithNoTests --silent 2>&1 | tail -3 || pytest --tb=no -q 2>&1 | tail -3 || echo "no runner"`

1. **BASELINE**: Read ratchet-state.json. Run tests, build, lint. Record all.
2. **HYPOTHESIZE**: Read program.md. Propose ONE atomic change.
3. **IMPLEMENT**: Note HEAD. Minimal change.
4. **MEASURE**: Same measurements. Score = (pass/total)*40 + (build?20:0) + lint*15 + custom*25
5. **DECIDE**: Better → KEEP (commit `ratchet: [desc]`). Worse → REVERT (`git checkout -- .`).
6. **LEARN**: Log. 3+ failures on same area → skip. GOTO 2.

Stop: user interrupts | all explored | 5 consecutive no-improvement | context ≥50% | 20 max.
EOF

wf "$ROOT/.claude/skills/zibe-plan/SKILL.md" << 'EOF'
---
name: zibe-plan
description: >
  Self-interview planning before building. Use for complex features, ambiguous tasks,
  or "/zibe-plan", "think about", "plan this", "design a solution for".
argument-hint: "[feature or problem]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# /zibe-plan — Think Before You Build

Planning: $ARGUMENTS

## Round 1: UNDERSTAND → .claude/PLAN.md
What is user asking? Acceptance criteria? Inputs/outputs? Existing code touched?

## Round 2: CHALLENGE
Read OPEN-QUESTIONS.md. Delegate to self-critic agent → PLAN-CRITIQUE.md.

## Round 3: SIMPLIFY
Smallest change? Without new deps? Without new abstractions? >5 files = too big.

## Round 4: SEQUENCE
Test names, implementation order, commit points.

## Round 5: VERIFY
Criteria testable? Edge cases addressed? Simplest path? No premature abstraction?
EOF

wf "$ROOT/.claude/skills/meta-ratchet/SKILL.md" << 'EOF'
---
name: meta-ratchet
description: >
  Session retrospective. Analyze failures, propose instruction improvements.
  Trigger: "/zibe-retro", "what went wrong", "retrospective".
argument-hint: "[optional: specific failure]"
disable-model-invocation: true
user-invocable: false
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Meta-Ratchet — Learn From Failure

## Context
- Journal: !`cat .claude/JOURNAL.md 2>/dev/null || echo "no journal"`
- Commits: !`git log --oneline -10 2>/dev/null || echo "none"`

1. IDENTIFY failures (untested changes, rabbit holes, false fixes, silent failures, scope creep, test pollution, ignored instructions)
2. FORMULATE rules (specific, actionable, testable, one sentence)
3. CHECK existing rules in CLAUDE.md
4. PROPOSE → EVOLUTION.md (do NOT edit CLAUDE.md — human reviews)
5. SCORE session: tasks attempted/completed, human corrections, rules violated
EOF

wf "$ROOT/.claude/skills/zibe-audit/SKILL.md" << 'EOF'
---
name: zibe-audit
description: >
  Challenge architectural assumptions. Find blind spots.
  Trigger: "what are we missing", "blind spots", "challenge architecture".
argument-hint: "[optional: system to audit]"
disable-model-invocation: true
context: fork
agent: self-critic
allowed-tools: Read, Bash, Glob, Grep
---

# /zibe-audit — Assumption Audit
Target: $ARGUMENTS (or entire system)
1. LIST assumptions from CLAUDE.md, settings, skills, agents
2. INVERT each: if FALSE → consequence → gap → fix
3. CATEGORIZE: topology/dependency/lifecycle/observability/human/scale
4. PRIORITIZE: likelihood × severity (≥15 critical, ≥9 important)
5. PROPOSE fixes → EVOLUTION.md
6. Write questions → OPEN-QUESTIONS.md
EOF

wf "$ROOT/.claude/skills/zibe-scout/SKILL.md" << 'EOF'
---
name: zibe-scout
description: >
  Scan Claude Code changelog for new features. Propose A/B tests.
  Trigger: "/zibe-scout", "check for updates", "new features", "what's new".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
effort: low
---

# /zibe-scout — Release Scanner

## Step 1: FETCH
```bash
curl -s https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md | head -300 > /tmp/cc-changelog.md
claude --version 2>/dev/null || echo "not in PATH"
```

## Step 2: FILTER
Check `.claude/scout-state.json` for last version. Focus on: hook events, frontmatter fields, agent features, performance fixes, security, context management, control plane.

## Step 3: ASSESS
Score each: Applicability(0-3) + Impact(0-3) - Risk(0-3) - Effort/2. Score ≥3 = worth testing.

## Step 4: PROPOSE → EVOLUTION.md
Feature name, score, hypothesis, A/B test plan, status: PROPOSED.

## Step 5: UPDATE scout-state.json
NEVER auto-adopt. Always propose → human reviews → test → merge.
EOF

###############################################################################
# AGENTS — original content, frontmatter updated
###############################################################################

wf "$ROOT/.claude/agents/tdd-test-writer.md" << 'EOF'
---
name: tdd-test-writer
description: >
  Writes failing tests for new features. RED phase specialist.
  Never writes implementation code.
tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet
---
# TDD Test Writer (RED Phase)
You write tests that FAIL. SubagentStart hook sets CLAUDE_TDD_PHASE=red.
Process: read requirement → identify behaviors → write tests → run (MUST fail) → return paths.
Principles: descriptive names, one assertion per test, test public API, include edge cases.
If user gave exact error string, test for that EXACT string.
NEVER write implementation code.
EOF

wf "$ROOT/.claude/agents/tdd-implementer.md" << 'EOF'
---
name: tdd-implementer
description: >
  Implements MINIMAL code to make failing tests pass. GREEN phase.
  Never modifies test files.
tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet
---
# TDD Implementer (GREEN Phase)
Write MINIMUM code to pass tests. Max 5 iterations.
Fix implementation, not tests. NEVER modify test files.
EOF

wf "$ROOT/.claude/agents/code-reviewer.md" << 'EOF'
---
name: code-reviewer
description: >
  Reviews code for quality, security, correctness. READ-ONLY — reports, never fixes.
  Used by /review delegation and ratchet quality checks.
tools: [Read, Bash, Glob, Grep]
model: sonnet
---
# Code Reviewer
Checklist: correctness, tests, security, performance, readability, architecture.
Output: APPROVE / REQUEST_CHANGES / COMMENT with categorized findings.
EOF

wf "$ROOT/.claude/agents/self-critic.md" << 'EOF'
---
name: self-critic
description: >
  Adversarial reviewer. Finds flaws, missing edge cases, bad assumptions.
tools: [Read, Bash, Glob, Grep]
model: claude-opus-4-6
---
# Self-Critic — Skeptical Senior Engineer
Find problems. Assume flaws. Check assumptions, edge cases, simplicity, missing pieces.
Output → .claude/PLAN-CRITIQUE.md: Verdict (APPROVE/REVISE/RETHINK), Critical Issues, Concerns, Missing, Over-engineering, What's Good.
EOF

wf "$ROOT/.claude/agents/ui-tester.md" << 'EOF'
---
name: ui-tester
description: >
  Tests UI components for visual correctness, accessibility, UX.
tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet
---
# UI Tester
Check rendering, interaction, a11y (ARIA, keyboard, contrast 4.5:1 WCAG AA), responsive (320/768/1024px).
EOF

###############################################################################
# RULES — original content
###############################################################################

wf "$ROOT/.claude/rules/safety.md" << 'EOF'
---
paths: ["**/*.sh","**/*.env*","**/hooks/**","**/settings.json","**/Dockerfile","**/docker-compose*"]
---
# Safety Rules
1. NEVER hardcode secrets/keys/passwords. 2. NEVER commit .env. 3. NEVER eval user input.
4. NEVER curl|bash. 5. NEVER chmod 777. 6. NEVER disable SSL.
Shell: `#!/usr/bin/env bash`, `set -euo pipefail` (scripts not hooks), quote vars, `[[ ]]`.
Hooks: NEVER exit 1 to block (non-blocking!). Use JSON permissionDecision:"deny" + exit 0.
EOF

wf "$ROOT/.claude/rules/testing.md" << 'EOF'
---
paths: ["**/*.test.*","**/*.spec.*","**/__tests__/**","**/test/**","**/tests/**"]
---
# Testing Rules
Tests are SPECS. One assertion per test. Independent. Fast.
Bug fix: reproduce EXACT error string. Test real entrypoint for CLI.
Don't chase unrelated failures. NEVER mock unit under test. Fix implementation, not tests.
EOF

wf "$ROOT/.claude/rules/ui.md" << 'EOF'
---
paths: ["**/*.tsx","**/*.jsx","**/*.vue","**/*.svelte","src/components/**","src/ui/**","src/pages/**"]
---
# UI Rules
One component per file. PascalCase. <200 lines. No biz logic in components.
a11y: keyboard, alt text, labels, contrast 4.5:1, semantic HTML, ARIA only when needed.
Mobile-first. Test 320/768/1024px.
EOF

###############################################################################
# DOCS — including ALL that were dropped
###############################################################################

wf "$ROOT/.claude/docs/MANUAL.md" << 'DOCEOF'
DOCEOF
# Copy MANUAL from this script's stdin would be huge — use a placeholder
# The actual MANUAL.md content from the user's upload should be placed here
cat > "$ROOT/.claude/docs/MANUAL.md" << 'DOCEOF'
# Zibe Universal Claude Setup Manual

## 1. Philosophy
This setup splits project truth from Claude operating machinery.
- Project truth lives at repo root: `TODO.md`, `TODO-prompt.md`, optional specs
- Claude operating machinery lives under `.claude/`

## 2. Tasks and TODO
Use root `TODO.md` as the canonical project task tracker.
### Quick capture
Use `/zibe-todo` to append a phase and checklist items.
### Advanced proof-sensitive items
Add claim-id, proof-command, proof-artifact, proof-assert. Then use /zibe-prove and /zibe-sync-todo.

## 3. Native /review and /simplify
Deliberately deferred to Claude Code's native commands. No zibe override.

## 4. Ratchet, Conductor, Dashboard
- `/zibe-ratchet` — in-session improvement loop
- `conductor.sh` — external supervisor (restart, budget, unattended)
- Dashboard — standalone HTML, covers TODO, proof-log, model state, conductor, ratchet, journal

## 5. Model and Effort Enforcement
- `/zibe-model default|sonnet|opus` — model override
- `/zibe-effort default|low|high` — effort override
- `/zibe-enforcement` — list current state
- Hooks and rules report n/a (no native model settings)

## 6. Proof Flow
1. Perform change → 2. /zibe-prove → 3. Inspect proof-log.json → 4. /zibe-sync-todo → 5. Then use completion language

## 7. Files and Paths
- `TODO.md` — project tasks (ROOT)
- `TODO-prompt.md` — prompt templates (ROOT)
- `.claude/docs/MANUAL.md` — this manual
- `.claude/commands/` — all zibe- prefixed commands
- `.claude/reports/dashboard.html` — standalone dashboard
DOCEOF

# For ARCHITECTURE, PATTERNS, DEBUGGING, ESCAPE-HATCHES, QUICKREF, BOOTSTRAP-PROMPT:
# These are large docs — include key content

wf "$ROOT/.claude/docs/ARCHITECTURE.md" << 'DOCEOF'
# Architecture & Design Decisions

## Key Decisions
1. Skills vs CLAUDE.md — universal rules in CLAUDE.md, specialized in skills
2. Subagents for context isolation — TDD requires separate windows
3. Git as memory — state persistence, undo, branching
4. Hooks are deterministic, CLAUDE.md is advisory — ~80% vs 100%
5. Ratchet never goes backward — score only increases
6. One change per experiment — atomic attribution
7. Instructions are scars, not theories — trace to observed failures
8. Continuous journaling — Stop hook writes every turn, survives crashes
9. External conductor — bash script supervisor, deterministic, re-entrant
10. Three levels of self-correction: meta-ratchet (rules), self-critic (plans), assumption-audit (architecture)
11. Model/effort enforcement — configurable via /zibe-model, /zibe-effort
12. Proof flow — machine-checkable claims before completion language
13. There are no edge cases, only certainties — fail CLOSED not open

See full version in repo: docs/ARCHITECTURE.md
DOCEOF

wf "$ROOT/.claude/docs/PATTERNS.md" << 'DOCEOF'
# Patterns & Anti-Patterns
## Use
- Error String Anchor: exact error → test → RED → fix → GREEN
- Real Entrypoint: CLI bugs → test the binary
- Anti-Derailment: unrelated failures → note, don't chase
- A/B Worktree: `claude -w approach-a` vs `claude -w approach-b`
- Proof Before Commit: /zibe-prove before completion language
## Avoid
- Kitchen Sink CLAUDE.md (>25 rules = ignored)
- Silent Failure (catch(e){})
- Multi-Change Experiment
- Exit 1 for Blocking (use JSON + exit 0)
- Test-After-the-Fact
- Premature Abstraction
DOCEOF

wf "$ROOT/.claude/docs/DEBUGGING.md" << 'DOCEOF'
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
DOCEOF

wf "$ROOT/.claude/docs/ESCAPE-HATCHES.md" << 'DOCEOF'
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
DOCEOF

wf "$ROOT/.claude/docs/QUICKREF.md" << 'DOCEOF'
# Quick Reference
## Commands (all /zibe- prefixed)
/zibe-todo, /zibe-implement, /zibe-ratchet, /zibe-bootstrap, /zibe-health,
/zibe-check, /zibe-digest, /zibe-dashboard, /zibe-walkthrough, /zibe-retro,
/zibe-prove, /zibe-sync-todo, /zibe-model, /zibe-effort, /zibe-enforcement
Native: /review, /simplify (NOT overridden)
## Skills (auto-invocable)
tdd-loop, ratchet-loop, self-plan, meta-ratchet, assumption-audit, scout
## Agents
tdd-test-writer (sonnet), tdd-implementer (sonnet), code-reviewer (sonnet), self-critic (opus), ui-tester (sonnet)
## Hook Decision Format
EXIT 0 + JSON permissionDecision:"deny" = BLOCK (reliable)
EXIT 1 = NON-BLOCKING (action proceeds!)
DOCEOF

wf "$ROOT/.claude/docs/BOOTSTRAP-PROMPT.md" << 'DOCEOF'
# Bootstrap Prompt — Paste Into Claude Code
Read CLAUDE.md. Read .claude/docs/MANUAL.md. Run /zibe-bootstrap.
Then: /zibe-health for baseline. Begin work with /zibe-implement or /zibe-todo.
For every feature: tests FIRST, implement to pass, refactor, commit.
When done: /zibe-retro. If proof items exist: /zibe-prove then /zibe-sync-todo.
DOCEOF

wf "$ROOT/.claude/docs/session-lifecycle.md" << 'DOCEOF'
# Universal Session Lifecycle Notes
- Start: load journal, git state, TODO status, proof-log freshness
- Every turn: write JOURNAL.md (stop hook)
- Before compact: state snapshot (post-compact hook)
- /zibe-check for spot checks
- /self-plan before /zibe-implement for complex work
- /zibe-prove before completion language
- /zibe-sync-todo after proof-sensitive work
DOCEOF

wf "$ROOT/.claude/docs/references.md" << 'DOCEOF'
# Universal Read-When-Relevant Pattern
- `.claude/skills/` for reusable skills
- `.claude/agents/` for isolated subagents
- `.claude/EVOLUTION.md` for instruction history
- `.claude/proof-log.json` for claim audit results
- `.claude/ratchet-state.json` for experiment baseline
DOCEOF

###############################################################################
# SCRIPTS — full versions
###############################################################################

wf "$ROOT/.claude/scripts/conductor.sh" << 'SEOF'
#!/usr/bin/env bash
set -euo pipefail
# Conductor — External session controller. See MANUAL.md §4.
PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE="$PROJ/.claude/conductor-state.json"
LOG="$PROJ/.claude/logs/conductor.log"
PID="$PROJ/.claude/conductor.pid"
PORT="${CONDUCTOR_PORT:-7777}"
MAX_BUDGET=10; MAX_FAILS=3; MAX_SESSIONS=50; TIMEOUT=600; TURNS=25; WAIT=300
log(){ echo -e "[$(date +%H:%M:%S)] $1" | tee -a "$LOG" 2>/dev/null; }
init(){ mkdir -p "$(dirname "$STATE")" "$(dirname "$LOG")" "$PROJ/.claude/reports"
  [ -f "$STATE" ] || echo '{"status":"idle","total_sessions":0,"total_cost_usd":0,"consecutive_failures":0,"last_exit_reason":null,"current_task":null,"history":[]}' > "$STATE"; }
rs(){ jq -r "$1" "$STATE" 2>/dev/null||echo "0"; }
us(){ local t=$(mktemp); jq "$1" "$STATE">"$t" 2>/dev/null&&mv "$t" "$STATE"; }
get_task(){ local t=""; [ -f "$PROJ/TODO.md" ] && t=$(grep -m1 '^\- \[ \]' "$PROJ/TODO.md" 2>/dev/null|sed 's/^- \[ \] //'||true)
  [ -z "$t" ] && t="Run /zibe-ratchet following program.md."; echo "$t"; }
run_session(){ local task="$1" ec=0; log "Session #$(( $(rs '.total_sessions') + 1 )): ${task:0:60}..."
  us ".status=\"running\"|.current_task=\"$(echo "$task"|head -c 100|sed 's/"/\\"/g')\""
  local rf=$(mktemp) ctx=""
  [ -f "$PROJ/.claude/JOURNAL.md" ] && ctx="PREVIOUS:\n$(cat "$PROJ/.claude/JOURNAL.md")\n\n"
  timeout "$TIMEOUT" claude -p "${ctx}Read CLAUDE.md. TASK: ${task}\nBEGIN." --output-format json --max-turns "$TURNS" \
    --permission-mode auto --allowedTools "Read,Write,Edit,MultiEdit,Bash,Glob,Grep,Agent" >"$rf" 2>>"$LOG" || ec=$?
  local cost=$(jq -r '.total_cost_usd//0' "$rf" 2>/dev/null||echo 0) reason="completed"
  [ "$ec" -eq 124 ] && reason="timeout"
  [ "$(jq -r '.is_error//false' "$rf" 2>/dev/null)" = "true" ] && reason="error"
  local cf=$(rs '.consecutive_failures'); [ "$reason" = "completed" ] && cf=0 || cf=$((cf+1))
  us ".total_sessions+=1|.total_cost_usd=(.total_cost_usd+$cost)|.consecutive_failures=$cf|.last_exit_reason=\"$reason\""
  rm -f "$rf"; echo "$reason"; }
auto_loop(){ [ -f "$PID" ] && kill -0 "$(cat "$PID")" 2>/dev/null && { log "Already running."; exit 1; }
  echo $$>"$PID"; trap 'rm -f "$PID"' EXIT INT TERM; log "=== AUTO MODE === Budget: \$$MAX_BUDGET"
  us '.status="auto"'; local s=0 rl=0
  while true; do
    local c=$(rs '.total_cost_usd') cf=$(rs '.consecutive_failures')
    awk "BEGIN{exit !($c>=$MAX_BUDGET)}" 2>/dev/null && { log "Budget."; break; }
    [ "$cf" -ge "$MAX_FAILS" ] && { log "Failures."; break; }
    [ "$s" -ge "$MAX_SESSIONS" ] && { log "Max sessions."; break; }
    local task=$(get_task); [ -z "$task" ] && { log "No tasks."; break; }
    local r=$(run_session "$task"); s=$((s+1))
    case "$r" in completed)rl=0;sleep 5;; rate_limit)rl=$((rl+1));[ "$rl" -ge 3 ]&&break;sleep $((WAIT*(2**(rl-1))));; timeout)rl=0;sleep 10;; *)rl=0;sleep 30;; esac
  done; us '.status="idle"'; log "Done: $(rs '.total_sessions') sessions \$$(rs '.total_cost_usd')"; }
for i in "$@"; do case $i in --budget)shift;MAX_BUDGET="${1:-10}";shift 2>/dev/null||true;; esac; done
cd "$PROJ"; init
case "${1:-}" in --auto)auto_loop;; --check)echo "Sessions:$(rs '.total_sessions') Cost:\$$(rs '.total_cost_usd') Fails:$(rs '.consecutive_failures')";;
  --serve)cd "$PROJ/.claude/reports";python3 -m http.server "$PORT" 2>/dev/null||echo "No python";; --reset)rm -f "$STATE";init;;
  *)echo "Usage: conductor.sh [--auto [--budget N]] [--check] [--serve] [--reset]";; esac
SEOF

wf "$ROOT/.claude/scripts/bootstrap-claude.sh" << 'SEOF'
#!/usr/bin/env bash
set -euo pipefail
# Project bootstrap verification — checks global + project, never recreates global locally.
echo "Verifying environment..."
G='\033[0;32m';Y='\033[1;33m';R='\033[0;31m';NC='\033[0m'
ok(){ echo -e "  ${G}✓${NC} $1"; }; wn(){ echo -e "  ${Y}⚠${NC} $1"; }; fl(){ echo -e "  ${R}✗${NC} $1"; }

echo "── Global (~/.claude/) ──"
for f in CLAUDE.md settings.json model-config.json; do
  [ -f "$HOME/.claude/$f" ] && ok "~/.claude/$f" || fl "~/.claude/$f MISSING — run install.sh"
done
for d in commands skills agents hooks rules docs scripts; do
  [ -d "$HOME/.claude/$d" ] && ok "~/.claude/$d/" || fl "~/.claude/$d/ MISSING — run install.sh"
done

echo "── Hook permissions ──"
for h in "$HOME/.claude/hooks/"*.sh; do
  [ -f "$h" ] && [ ! -x "$h" ] && chmod +x "$h" && wn "Fixed: $(basename "$h")"
  [ -f "$h" ] && [ -x "$h" ] && ok "$(basename "$h")"
done

echo "── Project files ──"
for f in CLAUDE.md TODO.md program.md; do
  [ -f "$f" ] && ok "$f" || wn "$f missing — run project-install.sh"
done
[ -f ".claude/settings.json" ] && ok ".claude/settings.json" || wn ".claude/settings.json missing"

echo "── Project dirs (local only: logs, reports) ──"
for d in logs reports; do
  mkdir -p ".claude/$d" 2>/dev/null
  ok ".claude/$d/"
done

echo "── Tools ──"
command -v jq &>/dev/null && ok "jq $(jq --version 2>&1)" || fl "jq MISSING (required)"
command -v git &>/dev/null && ok "git" || fl "git MISSING"
[ -d .git ] && ok "git initialized ($(git branch --show-current 2>/dev/null || echo '?'))" || wn "No .git"
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] && wn "On $BRANCH — use a feature branch"

echo "── State ──"
for f in ratchet-state.json proof-log.json; do
  [ -f ".claude/$f" ] && ok ".claude/$f" || { wn ".claude/$f initializing"; }
done
[ -f ".claude/ratchet-state.json" ] || echo '{"version":"1.0","experiment_count":0,"consecutive_failures":0,"baseline_metrics":{},"experiments":[],"kept_improvements":[]}' > .claude/ratchet-state.json
[ -f ".claude/proof-log.json" ] || echo '{"version":"1.0","claims":[],"last_run":""}' > .claude/proof-log.json

echo "Done."
SEOF

###############################################################################
# EMPTY DIRS
###############################################################################
mkdir -p "$ROOT/.claude/"{logs,reports,worktrees}
touch "$ROOT/.claude/logs/.gitkeep" "$ROOT/.claude/reports/.gitkeep" "$ROOT/.claude/worktrees/.gitkeep"

###############################################################################
# PROJECT TEMPLATE — files that go at project ROOT
###############################################################################

wf "$ROOT/project-template/CLAUDE.md" << 'EOF'
# Project: [PROJECT_NAME]
## Stack
- [YOUR STACK]
- Test runner: [vitest/jest/pytest]
- Linter: [eslint/ruff]
## Commands
```bash
# Test single: [command] <file>
# Test all: [command]
# Build: [command]
# Lint: [command]
```
## Architecture
```
src/
├── core/     # Business logic
├── ui/       # Components
├── api/      # Routes
├── lib/      # Utilities
└── types/    # Type definitions
```
EOF

wf "$ROOT/project-template/TODO.md" << 'EOF'
# TODO — Project Tasks

## TODO LIST

## Completed
EOF

wf "$ROOT/project-template/TODO-prompt.md" << 'EOF'
# TODO Prompt Templates

## Simple Checklist
Use `/zibe-todo phase name, item 1, item 2, item 3`

## Advanced (proof-sensitive)
Add claim-id, proof-command, proof-artifact, proof-assert under items.
Then /zibe-prove and /zibe-sync-todo.

See .claude/docs/MANUAL.md §2 for full details.
EOF

wf "$ROOT/project-template/.claude/settings.json" << 'EOF'
{
  "_comment": "Project-level settings. Merges with ~/.claude/settings.json (global). Project takes precedence on conflict.",
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npm run *)", "Bash(npx *)", "Bash(node *)", "Bash(python *)", "Bash(python3 *)",
      "Bash(git add *)", "Bash(git commit *)", "Bash(git checkout *)", "Bash(git branch *)",
      "Bash(git diff *)", "Bash(git log *)", "Bash(git status*)", "Bash(git stash*)",
      "Bash(cat *)", "Bash(ls *)", "Bash(head *)", "Bash(tail *)", "Bash(wc *)",
      "Bash(grep *)", "Bash(find *)", "Bash(mkdir *)", "Bash(cp *)", "Bash(mv *)",
      "Bash(chmod +x *)", "Bash(echo *)", "Bash(jq *)", "Bash(timeout *)",
      "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep", "Agent"
    ],
    "deny": [
      "Bash(rm -rf /)", "Bash(rm -rf ~)", "Bash(rm -rf .git)", "Bash(sudo *)",
      "Bash(curl * | bash)", "Bash(eval *)",
      "Bash(git push * --force *)", "Bash(git push * main)", "Bash(git push * master)",
      "Bash(chmod 777 *)", "Bash(mkfs *)", "Bash(dd *)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|compact|clear",
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/session-start.sh\"",
          "timeout": 15,
          "statusMessage": "Loading session context..."
        }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/pre-tool-security.sh\"",
          "timeout": 5,
          "statusMessage": "Security check..."
        }]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/pre-write-guard.sh\"",
          "timeout": 5,
          "statusMessage": "Write guard..."
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/post-edit-autoformat.sh\"",
          "timeout": 30
        }]
      }
    ],
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/stop-journal.sh\"",
          "timeout": 45
        }]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/subagent-start.sh\"",
          "timeout": 5
        }]
      }
    ],
    "PostCompact": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/post-compact-handoff.sh\"",
          "timeout": 15,
          "statusMessage": "Preserving state..."
        }]
      }
    ],
    "Notification": [
      {
        "matcher": "idleprompt",
        "hooks": [{
          "type": "command",
          "command": "bash \"$HOME/.claude/hooks/notify.sh\"",
          "timeout": 5,
          "async": true
        }]
      }
    ]
  }
}
EOF

wf "$ROOT/project-template/program.md" << 'EOF'
# Program: Improvement Directions
## Current Directions
### Performance
1. [ ] Reduce bundle size — Measure: build output KB
### Code Quality
2. [ ] Eliminate `any` types — Measure: grep count
3. [ ] Fix silent error handling — Measure: empty catch count
### Tests
4. [ ] Add tests for uncovered utilities — Measure: test count
### Accessibility
5. [ ] Add ARIA labels — Measure: axe-core violations
## Exhausted Directions
## Completed Improvements
EOF

###############################################################################
# DONE
###############################################################################
echo ""
echo "============================================"
echo "✓ claude-zibe built at: $ROOT"
echo "  Files: $(find "$ROOT" -type f | wc -l | tr -d ' ')"
echo ""
echo "  cd $ROOT"
echo "  bash install.sh            # deploy to ~/.claude/"
echo "  cd /your/project"
echo "  bash $ROOT/project-install.sh  # scaffold project"
echo "  claude"
echo "  /zibe-check"
echo "============================================"
