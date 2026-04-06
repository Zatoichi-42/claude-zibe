# Bootstrap v2 — Migration Guide & Root Cause Analysis

## What Failed (and Why)

Your Phase 3 implementation achieved partial completion. The completion report shows:

| Category | Items at 0% | Root Cause |
|---|---|---|
| Sector-relative returns | 3 items | Never attempted — session stalled before reaching these |
| Hit rate by setup/bucket | 4 items | Code exists but output fields are "empty-by-construction" |
| Early-discovery evaluation | 3 items | Never attempted |
| Calibration summaries | 2 items | Skeleton exists but CLI feeds empty input |
| Universe median comparison | 1 item | Never attempted |

### 7 Root Causes Identified

**CLASS 1: Bootstrap never activated**

1. **Write-guard hook blocked TDD subagent** — The `pre-write-guard.sh` checked for
   `CLAUDE_TDD_PHASE` env var, which subagents cannot inherit. The tdd-test-writer
   subagent tried to create test files → hook blocked it → session stalled silently
   for ~45 minutes until human intervened.

2. **No fallback when subagents stall** — The TDD skill delegated to subagents with no
   timeout or fallback. When the write-guard blocked the subagent, the parent session
   had no mechanism to detect the stall and switch to direct implementation.

3. **Ceremony overload** — The Proof Protocol required 3 commands (`/zibe-prove` →
   `/zibe-sync-todo` → commit) to close one item. This ceremony was never executed
   because implementation stalled first. proof-log.json: `{"claims":[]}`.

**CLASS 2: TODO → Implementation chain disconnected**

4. **TODO items lack machine-checkable criteria** — Phase 3 TODO items like "Compute
   sector-relative forward returns" had no `proof-command:` annotations. Even if
   `/zibe-prove` had run, it would have found nothing to verify.

5. **No auto-annotation of proof-commands** — The `/zibe-plan` skill produces PLAN.md
   with acceptance criteria, but nothing converts those criteria into TODO items with
   `proof-command:` metadata. This was a manual gap in an "autonomous" pipeline.

**CLASS 3: Session management failures**

6. **Single mega-session** — Debug log shows `tokens=123339` (64% context) with 215
   messages. The session ran /zibe-implement multiple times, stalled, restarted, stalled
   again. Classic mega-session anti-pattern.

7. **No per-item progress tracking** — When one item stalled, ALL remaining items
   stopped. No mechanism to skip blocked items and continue with others.

---

## What Changed: v1 → v2

### Files Removed (35+ → 43 files, but simpler)
- Removed `zibe-` prefix from all commands (unnecessary namespace)
- Removed `/zibe-sync-todo` (merged into `/prove`)
- Removed `/zibe-prove` ceremony (replaced with single `/prove`)
- Removed model-config.json (not needed until you have budget controls)
- Removed model-enforcement (same)
- Removed policy-limits.json (same)
- Removed dashboard/walkthrough/scout commands (premature — build these after the core loop works)

### Critical Fixes

| Fix | File | What Changed |
|---|---|---|
| **Write-guard detects agent context** | `hooks/pre-write-guard.sh` | Checks agent_name from JSON + marker file instead of env var |
| **TDD skill creates marker file** | `skills/tdd-loop/SKILL.md` | `touch .claude/.tdd-red-phase` before subagent, `rm` after |
| **Subagent fallback** | `skills/tdd-loop/SKILL.md` | After 2 failed attempts → direct implementation |
| **Skip-and-continue** | `skills/tdd-loop/SKILL.md` | Stuck items go to BLOCKED.md, session continues |
| **One-command proof** | `commands/prove.md` | Single `/prove` runs proof, updates TODO, commits |
| **Auto proof-commands** | `skills/self-plan/SKILL.md` | `/plan` emits TODO items WITH proof-command annotations |
| **Bootstrap measures baseline** | `scripts/bootstrap.sh` | Populates ratchet-state.json during init, not deferred |
| **Session budget** | `CLAUDE.md` | Max 5 items per session, commit after each |

### New Files
- `.claude/BLOCKED.md` — tracks stuck items instead of stalling the session
- `.claude/.tdd-red-phase` — marker file for write-guard (created/removed by TDD skill)

### Hook Changes

**pre-write-guard.sh** (the #1 fix):
```bash
# OLD (broken): env var that subagents can't inherit
if [ "${CLAUDE_TDD_PHASE:-}" != "red" ]; then
  # block test file writes
fi

# NEW: 3 detection methods, any one allows test writing
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // empty')
if [ "$AGENT_NAME" = "tdd-test-writer" ]; then exit 0; fi
if [ "${CLAUDE_TDD_PHASE:-}" = "red" ]; then exit 0; fi
if [ -f ".claude/.tdd-red-phase" ]; then exit 0; fi
```

**settings.json**: Hooks now use project-relative paths (`bash .claude/hooks/...`)
instead of `$HOME/.claude/hooks/...` — works correctly in any project directory.

### CLAUDE.md Changes
- Reduced from ~60 lines to ~50, every rule has a named scar
- Removed Proof Protocol ceremony (3 commands → just "run tests → commit → update TODO")
- Added session discipline: max 5 items, commit after each
- Added stuck protocol: 3 attempts → BLOCKED.md → skip

### TODO.md Changes
- Every item now has `proof-command:` annotation
- Items ordered by dependency (foundation → core → integration → tests)
- `/prove` command reads these and auto-validates

---

## Installation

### New Project
```bash
# Unzip into your project root
unzip bootstrap-v2.zip -d /path/to/your/project/

# Customize CLAUDE.md with your stack
# Customize TODO.md with your tasks (keep proof-commands!)
# Customize program.md with your improvement directions

# Make hooks executable
chmod +x .claude/hooks/*.sh .claude/scripts/*.sh

# Start Claude Code and run:
/bootstrap
```

### Existing Project (upgrading from v1)
```bash
# Back up your current .claude/
cp -r .claude .claude.backup

# Unzip v2 overtop
unzip -o bootstrap-v2.zip -d .

# Restore your project-specific settings:
# - Copy your stack info back into CLAUDE.md
# - Copy your TODO items (add proof-commands to each!)
# - Copy your program.md directions

# Fix permissions
chmod +x .claude/hooks/*.sh .claude/scripts/*.sh

# Start Claude Code and run:
/bootstrap
/health
```

---

## The Key Insight

The v1 bootstrap had 40+ files of scaffolding but the actual session history shows:
login → check → bootstrap (twice) → health → plan → implement (stuck) → human
intervention → partial completion. **The scaffolding created overhead without
creating guardrails that actually fired.**

v2 fixes this by:
1. Making hooks work correctly with subagents (marker file pattern)
2. Adding fallbacks so stalls never block the session
3. Making proof-commands a first-class part of TODO items
4. Reducing ceremony from 3 commands to 1
5. Enforcing per-item commits instead of mega-sessions
6. Initializing baseline during bootstrap instead of deferring

Every change traces to a specific, observed failure from the Phase 3 run.
