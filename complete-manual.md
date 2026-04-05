# Zibe — Complete System Manual

## Table of Contents
1. What Zibe Is
2. Installation
3. New Project Setup
4. System Architecture
5. The TODO System
6. The Proof System
7. Commands Reference
8. Skills Reference
9. Agents Reference
10. Hooks Reference
11. Model & Effort Enforcement
12. The Ratchet Loop
13. The Conductor
14. The Dashboard & Reports
15. Session Lifecycle
16. Daily Workflow
17. Evolution & Self-Improvement
18. Context Management
19. Git Workflow
20. Debugging
21. Maintenance
22. Iteration Advice

---

## 1. What Zibe Is

Zibe is a global Claude Code bootstrap that installs to `~/.claude/` and applies automatically to every project under your home directory. It provides:

- **15 slash commands** (`/zibe-*`) for task management, TDD, improvement loops, proofs, model control, reporting, and retrospectives
- **6 skills** that Claude can auto-invoke when conversation context matches
- **5 subagents** with isolated context windows for TDD, review, and adversarial critique
- **8 hooks** that enforce rules deterministically (hooks fire 100% of the time; CLAUDE.md instructions fire ~80%)
- **A proof system** for machine-checkable claims before work is marked complete
- **A model/effort enforcement system** for controlling which model and thinking depth Claude uses
- **An external conductor** for unattended overnight operation
- **A self-improvement loop** (meta-ratchet) that proposes instruction changes from observed failures

The core philosophy: **project truth lives at the repo root** (TODO.md, program.md, specs). **Claude operating machinery lives under `.claude/`** (commands, hooks, scripts, rules, state files). This separation means your project files are always human-readable and tool-agnostic, while the Claude infrastructure is portable across projects.

---

## 2. Installation

### Prerequisites
- **jq** — Required. Every hook depends on it. Without jq, all security hooks fail closed (block everything). Install: `brew install jq` (macOS), `apt install jq` (Ubuntu/Debian), `apk add jq` (Alpine).
- **git** — Required for ratchet loop, session recovery, and normal development.
- **claude** — The Claude Code CLI itself.
- **Node.js or Python** — For test runners and formatters. Not strictly required but most projects need one.

### Steps

```bash
# Clone the repo
git clone https://github.com/Zatoichi-42/claude-zibe.git
cd claude-zibe

# Run the installer
bash install.sh
```

What `install.sh` does (and only this):
1. **Backs up** existing `~/.claude/` to `~/.claude.backup.<timestamp>`
2. **Copies** every file from the repo's `.claude/` directory into `~/.claude/`
3. **Sets permissions** (`chmod +x`) on all hook and script `.sh` files
4. **Verifies** that jq, git, and claude are installed
5. **Checks** that all expected files arrived

The installer does not generate files, run code, or modify anything outside `~/.claude/`. If you need to reinstall, run it again — it's idempotent (backs up first, then copies fresh).

### After Installation

Open any project directory and run `claude`. The global `~/.claude/CLAUDE.md` loads automatically. Type `/zibe-check` to verify the system is active. You should see a spot-check report showing git status, test status, and next TODO item.

If `/zibe-check` doesn't appear in autocomplete, restart Claude Code — it discovers commands from `~/.claude/commands/` at startup.

---

## 3. New Project Setup

```bash
cd /your/project
bash /path/to/claude-zibe/project-install.sh
```

This copies five template files into your project root, skipping any that already exist:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project-specific constitution — add your stack, test runner, build commands |
| `TODO.md` | Canonical task tracker — lives at ROOT, not inside .claude/ |
| `TODO-prompt.md` | Templates for generating TODO items (simple and proof-sensitive) |
| `program.md` | Ratchet loop experiment directions |
| `.claude/settings.json` | Project-level hooks and permissions (merges with global ~/.claude/settings.json) |

The project `settings.json` is important for three reasons:
1. **Portability** — team members who clone the project get hook protection even without zibe installed globally
2. **Overrides** — project-specific hooks or permissions can be added here (project takes precedence over global on conflict)
3. **Visibility** — `git diff` on `.claude/settings.json` shows exactly what hooks are active for this project

### First Steps in a New Project

1. **Edit `CLAUDE.md`** — Replace the placeholder stack with your actual tech stack, test command, build command, and lint command. This is what Claude reads every session to understand your project.

2. **Edit `TODO.md`** — Add your Phase 1 tasks. Use `/zibe-todo` for quick capture or edit the file directly.

3. **Edit `program.md`** — Add improvement directions for the ratchet loop. Each direction is one hypothesis with a measurement.

4. **Run Claude Code:**
   ```
   claude
   /zibe-bootstrap    # verify environment
   /zibe-health       # establish baseline
   ```

### What /zibe-bootstrap Checks (and doesn't create)

The bootstrap verifies two layers:

**Global (`~/.claude/`)** — Checks that the zibe installation exists: CLAUDE.md, settings.json, model-config.json, and all subdirectories (commands, skills, agents, hooks, rules, docs, scripts). If anything is missing, it tells you to run `install.sh`. It does NOT recreate global infrastructure locally.

**Project** — Checks that CLAUDE.md, TODO.md, program.md, and `.claude/settings.json` exist at the project level. If missing, it tells you to run `project-install.sh`.

**Creates only what belongs per-project:**
- `.claude/logs/` — session logs (gitignored)
- `.claude/reports/` — generated reports (gitignored)
- `.claude/ratchet-state.json` — if missing, initializes empty
- `.claude/proof-log.json` — if missing, initializes empty

**Never creates locally:** commands/, skills/, agents/, hooks/, rules/, docs/, scripts/ — these are global-only and live in `~/.claude/`. Creating empty local versions would shadow the global setup.

5. **Start building:**
   ```
   /zibe-implement login form with email and password validation
   ```

---

## 4. System Architecture

```
HUMAN (direction setter)
    │
    ▼
CLAUDE.md (constitution — loaded every session)
    │
    ├── HOOKS (deterministic guards — fire 100%)
    │   8 scripts, 7 lifecycle events
    │
    ├── SKILLS (on-demand workflows — Claude auto-triggers)
    │   6 skills with frontmatter control
    │
    └── AGENTS (isolated context workers)
        5 subagents (separate context windows)
    │
    ▼
RATCHET LOOP (engine)
    Baseline → Hypothesize → Implement → Measure → Keep/Revert → Learn
    │
    ▼
GIT (memory & safety net)
    Atomic commits, worktrees, full rollback
```

### The Two Layers

**Layer 1: CLAUDE.md + Skills + Agents** — These are *advisory*. Claude follows them ~80% of the time. They define what Claude should do and how.

**Layer 2: Hooks** — These are *deterministic*. They fire 100% of the time. They define what Claude must never do (commit secrets, edit test files during implementation, force-push to main).

The rule of thumb: if violating a rule would cause real damage, put it in a hook. If violating a rule would cause quality issues, put it in CLAUDE.md.

### File Ownership

| Location | Owner | Contains |
|----------|-------|----------|
| Project root | Human | TODO.md, program.md, CLAUDE.md, source code, specs |
| `.claude/` | Zibe system | Commands, hooks, skills, agents, rules, state, reports |
| `~/.claude/` | Global Zibe | Same structure, applies to all projects |

Project-level `.claude/` merges with global `~/.claude/`. Project takes precedence on conflict.

---

## 5. The TODO System

TODO.md lives at the **project root** (not inside .claude/). It is the canonical task tracker. The conductor reads it to decide what to work on next. The session-start hook reports remaining task count. The dashboard displays it.

### Quick Capture

```
/zibe-todo API hardening, add retry budget, add timeout handling, add diagnostics
```

This parses the first segment as a phase heading and the rest as checklist items, appending to TODO.md:

```markdown
## API hardening
- [ ] add retry budget
- [ ] add timeout handling
- [ ] add diagnostics
```

### Manual Editing

You can always edit TODO.md directly. The format is standard markdown checkboxes:

```markdown
## Phase Name
- [ ] uncompleted item
- [x] completed item
```

### Proof-Sensitive Items

For work that should be machine-verifiable, add metadata under the checklist item:

```markdown
- [ ] Add transport_status to the emitted packet
  - claim-id: validation.transport_status
  - proof-command: python -m src.cli --output data/packets --mode validation
  - proof-artifact: latest.json
  - proof-assert: command_exit_zero
  - proof-assert: artifact_json_path_exists=meta.transport_status
```

These items are processed by `/zibe-prove` and `/zibe-sync-todo`. See §6.

### TODO-prompt.md

This file (also at project root) contains prompt templates for generating TODO items. It's a reference for both you and Claude — when you need to create a complex checklist, the templates show the expected format. See the file for simple and advanced examples.

---

## 6. The Proof System

The proof system prevents premature completion claims. Before you say "done" or check off a proof-sensitive item, the system verifies the claim with actual commands.

### The Flow

```
1. Do the work
2. /zibe-prove          ← runs proof commands, writes proof-log.json
3. Inspect results      ← check .claude/proof-log.json
4. /zibe-sync-todo      ← checks off proven items in TODO.md
5. THEN use completion language or commit
```

### /zibe-prove

Reads TODO.md, finds unchecked items with `claim-id:` and `proof-command:` metadata, runs each command, checks assertions, and writes results to `.claude/proof-log.json`.

Supported assertions:
- `command_exit_zero` — the proof command must exit with code 0
- `artifact_json_path_exists=<path>` — a JSON file must contain the specified path (e.g., `meta.transport_status`)

### /zibe-sync-todo

Reads proof-log.json, finds claims with status "pass", and checks off the corresponding items in TODO.md (changes `- [ ]` to `- [x]`). Reports how many items were checked off, how many are still failing, and how many haven't been proven yet.

### Why This Matters

Without the proof system, Claude tends to claim completion based on intent rather than verification. "I implemented the feature" doesn't mean the feature works. The proof system forces a machine-checkable verification step between implementation and completion, catching bugs that would otherwise slip through.

### When to Use Proofs

Not everything needs a proof. Use proofs for:
- Objective, verifiable claims (command produces correct output, file contains expected data)
- Phase-completion gates (all items in a phase must pass before moving on)
- Regression-sensitive work (the proof becomes a permanent check)

Don't use proofs for:
- Subjective quality (code readability, UX feel) — use `/review` instead
- Simple tasks where the test suite already covers it

---

## 7. Commands Reference

All commands are prefixed with `zibe-` to avoid collisions with Claude Code's native commands. Native `/review` and `/simplify` are deliberately NOT overridden.

### Task Management

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/zibe-todo` | Quick TODO capture | `phase name, item1, item2, item3` |
| `/zibe-prove` | Run proof commands for claim-id items | none |
| `/zibe-sync-todo` | Sync proof results to TODO.md checkmarks | none |

### Development

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/zibe-implement` | TDD feature build (delegates to tdd-loop skill) | `[feature description]` |
| `/zibe-bootstrap` | Init/verify project environment | none |
| `/zibe-ratchet` | Start autonomous improvement loop | `[focus area]` or blank |

### Model Control

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/zibe-model` | Override model globally | `default`, `sonnet`, or `opus` |
| `/zibe-effort` | Override effort globally | `default`, `low`, or `high` |
| `/zibe-enforcement` | Show current enforcement state | none |

### Reporting

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/zibe-check` | 30-second spot check (stdout only, no files) | none |
| `/zibe-health` | Comprehensive health check | none |
| `/zibe-digest` | Daily plain-text report | none |
| `/zibe-dashboard` | Generate HTML visual dashboard | none |
| `/zibe-walkthrough` | Generate interactive project tour | none |

### Self-Improvement

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/zibe-retro` | Session retrospective (delegates to meta-ratchet) | `[specific failure]` |

### Native Commands (NOT overridden)

| Command | Purpose |
|---------|---------|
| `/review` | Claude Code's native code review |
| `/simplify` | Claude Code's native refactoring |
| `/compact` | Compress conversation context |
| `/clear` | Reset context entirely |
| `/diff` | Show all changes Claude made |
| `/rewind` | Undo Claude's changes |

---

## 8. Skills Reference

Skills are on-demand workflows that Claude can auto-invoke when the conversation matches their description, or that you invoke explicitly with `/skill-name`. Skills load only their name and description at startup (no context penalty), then load full content when invoked.

| Skill | Auto-invocable? | Visible in / menu? | Human uses |
|-------|----------------|-------------------|------------|
| `tdd-loop` | Yes | **No** (hidden) | `/zibe-implement` command |
| `ratchet-loop` | Yes | **No** (hidden) | `/zibe-ratchet` command |
| `meta-ratchet` | No | **No** (hidden) | `/zibe-retro` command |
| `zibe-plan` | Yes | Yes | `/zibe-plan` directly |
| `zibe-audit` | No (human only) | Yes | `/zibe-audit` directly |
| `zibe-scout` | Yes | Yes | `/zibe-scout` directly |

Skills that duplicate a command's function are hidden from the `/` menu (`user-invocable: false`) so humans always see one clean entry point. Claude can still auto-invoke hidden skills when conversation context matches.

Everything in the `/` menu starts with `zibe-` — commands and visible skills alike. This namespaces the entire system away from native Claude Code commands and third-party plugins.

### tdd-loop

The core development workflow. Enforces Red-Green-Refactor with subagent isolation:
1. **PLAN** — Name tests first, define behaviors
2. **RED** — Delegate to `tdd-test-writer` agent (isolated context). Tests must FAIL.
3. **GREEN** — Delegate to `tdd-implementer` agent (isolated context). Minimum code to pass.
4. **REFACTOR** — Clean up in main context. Tests after every change.
5. **VERIFY** — Full suite + typecheck + lint.

Why subagents? When test-writing and implementation share context, Claude writes tests that pass by accident because it already knows the implementation. Separate context windows prevent this.

### ratchet-loop

The autonomous improvement engine. Six steps:
1. **BASELINE** — Measure everything (tests, build, lint, custom metrics)
2. **HYPOTHESIZE** — Propose ONE atomic change from program.md
3. **IMPLEMENT** — Make the minimal change
4. **MEASURE** — Run the same measurements
5. **DECIDE** — Better? KEEP (commit). Worse? REVERT (`git checkout -- .`)
6. **LEARN** — Log, pick next direction, repeat

The ratchet only turns one way. Quality score can only increase. Bad changes are reverted automatically. Maximum 20 experiments per session.

### zibe-plan

The planning skill. Self-interview before building complex features:
1. **UNDERSTAND** — Restate the problem, define acceptance criteria
2. **CHALLENGE** — Read OPEN-QUESTIONS.md, delegate to self-critic agent
3. **SIMPLIFY** — Smallest change? No new deps? No premature abstractions?
4. **SEQUENCE** — Name tests, order implementation, define commit points
5. **VERIFY** — All criteria testable? Edge cases addressed?

### zibe-scout

Scans Claude Code's changelog for new features relevant to your workflow. Scores each by applicability, impact, risk, and effort. Proposes A/B tests to EVOLUTION.md. Never auto-adopts — human reviews proposals.

---

## 9. Agents Reference

Agents are subagents with isolated context windows. They do a job and return results to the main conversation. They cannot see your conversation history.

| Agent | Model | Purpose |
|-------|-------|---------|
| `tdd-test-writer` | sonnet | RED phase — writes failing tests, never implementation code |
| `tdd-implementer` | sonnet | GREEN phase — minimum code to pass tests, never modifies tests |
| `code-reviewer` | sonnet | Read-only audit — reports findings, never fixes them |
| `self-critic` | opus | Adversarial plan review — finds flaws, assumptions, missing pieces |
| `ui-tester` | sonnet | UI + accessibility testing — rendering, interaction, WCAG AA |

### TDD Phase Management

The `tdd-test-writer` agent needs write access to test files, but the `pre-write-guard` hook normally blocks test file edits (to prevent Claude from modifying tests during implementation). This is resolved by the `SubagentStart` hook, which sets `CLAUDE_TDD_PHASE=red` in the environment when the test-writer agent spawns. The write guard checks this variable and allows test writes only during the red phase.

### self-critic on Opus

The self-critic deliberately uses opus (the most capable model) because plan critique requires deep reasoning. A cheaper model might rubber-stamp the plan instead of genuinely challenging it. The critic runs in an isolated context (separate from the planner) so it can't see the planner's reasoning and must evaluate the plan on its own merits.

---

## 10. Hooks Reference

Hooks are shell scripts that fire deterministically at specific points in Claude Code's lifecycle. Unlike CLAUDE.md instructions (which Claude might interpret flexibly), hooks execute the same way every time.

### Critical: How Blocking Works

```
EXIT 0 + JSON {"permissionDecision":"deny"}  = BLOCKS the action (RELIABLE)
EXIT 0 + no output                           = ALLOWS the action
EXIT 1                                       = NON-BLOCKING WARNING (action PROCEEDS!)
EXIT 2                                       = Blocks (less reliable than JSON)
```

**Exit 1 does NOT block.** This is the most common hook mistake. All Zibe hooks use JSON decision output with exit 0 for blocking.

### Hook Inventory

| Hook | Event | What It Does |
|------|-------|-------------|
| `pre-tool-security.sh` | PreToolUse:Bash | Blocks destructive commands, credential commits, disk ops |
| `pre-write-guard.sh` | PreToolUse:Write\|Edit | Blocks lock file edits, test file edits during implementation |
| `post-edit-autoformat.sh` | PostToolUse:Write\|Edit | Auto-formats edited files (prettier, black, gofmt, rustfmt) |
| `stop-journal.sh` | Stop | Writes JOURNAL.md every turn (survives crashes) |
| `session-start.sh` | SessionStart | Loads journal, injects env vars, fixes permissions, prunes logs |
| `post-compact-handoff.sh` | PostCompact | Writes HANDOFF.md after context compaction |
| `subagent-start.sh` | SubagentStart | Sets CLAUDE_TDD_PHASE=red for test-writer agent |
| `notify.sh` | Notification:idleprompt | Desktop notification when Claude needs attention |

### Infinite Loop Prevention

The Stop hook writes output, which Claude processes, which triggers another Stop. The `stop-journal.sh` hook checks `stop_hook_active` in the input JSON and exits immediately if true, breaking the cycle.

### Testing Hooks Manually

```bash
# Should output deny JSON:
echo '{"tool_input":{"command":"rm -rf /"}}' | bash ~/.claude/hooks/pre-tool-security.sh

# Should exit silently (allow):
echo '{"tool_input":{"command":"ls -la"}}' | bash ~/.claude/hooks/pre-tool-security.sh

# Should block test file edit:
echo '{"tool_input":{"file_path":"src/foo.test.ts"}}' | bash ~/.claude/hooks/pre-write-guard.sh
```

---

## 11. Model & Effort Enforcement

### The Problem

Claude Code uses different models and effort levels for different tasks, but there's no built-in way to enforce a specific model across all your agents, skills, and configurations at once. You might want opus everywhere during a critical architecture session, or sonnet everywhere to save cost during routine work.

### The Solution

Zibe provides three commands and four state files:

**Commands:**
- `/zibe-model default` — Restore original model settings from defaults
- `/zibe-model sonnet` — Force sonnet across all enforceable surfaces
- `/zibe-model opus` — Force opus across all enforceable surfaces
- `/zibe-effort default` — Restore original effort settings
- `/zibe-effort low` — Force low effort everywhere
- `/zibe-effort high` — Force high effort everywhere
- `/zibe-enforcement` — Show current state by scope and file

**State files:**
- `model-config.json` — Active tier configuration (tiers: high, standard, low)
- `model-config.defaults.json` — Snapshot of original defaults (for restoration)
- `model-enforcement.defaults.json` — Baseline state for reset
- `model-enforcement.state.json` — Current active override

**Enforceable surfaces:**
- Agent frontmatter `model:` field — Yes
- Skill content (effort references) — Yes
- Tier configuration in model-config.json — Yes
- Hooks — No (no native model setting, reported as `n/a`)
- Rules — No (no native model setting, reported as `n/a`)

### Typical Usage

```
# Architecture session — need deep thinking
/zibe-model opus
/zibe-effort high

# ... do architecture work ...

# Back to normal
/zibe-model default
/zibe-effort default

# Check what's active
/zibe-enforcement
```

---

## 12. The Ratchet Loop

The ratchet loop is an autonomous improvement cycle inspired by Karpathy's AutoResearch pattern. It proposes changes, measures their impact, and keeps only those that improve quality.

### When to Use

- You have a working codebase that could be better
- You've defined improvement directions in `program.md`
- You want Claude to explore improvements hands-off

### How It Works

The ratchet reads `program.md` for directions. Each direction is a hypothesis:

```markdown
1. [ ] Reduce bundle size by removing unused imports
   - Measure: `npm run build` output size in KB
   - Better = smaller
```

Claude picks the top unexplored direction, proposes ONE change, implements it, measures, and decides. If the score improved: commit with `ratchet: [description]`. If the score dropped: `git checkout -- .` and log the failure.

### Safety Rails

- Maximum 20 experiments per session
- Never modifies test files
- Commits each improvement individually (easy rollback)
- 3 consecutive failures on the same area → skip to next direction
- 5 consecutive failures total → stop the loop
- At 50% context → stop, commit, write journal

### The Score

```
score = (tests_passing / total_tests) × 40
      + (build_success ? 20 : 0)
      + max(0, (1 - lint_errors / max(baseline_lint, 1))) × 15
      + custom_metric_improvement × 25
```

The ratchet only turns one way. Score can only go up.

---

## 13. The Conductor

The conductor is a bash script that runs **outside** Claude Code. It's the supervisor that keeps work going through crashes, rate limits, and session limits.

### Why It Exists

Claude Code sessions die. Rate limits, token ceilings, crashes, laptop sleep — any of these kill the session. When the session dies, nothing inside it can restart work. The conductor runs outside, detects the death, and spawns a new session.

### Usage

```bash
# From your project root:
bash .claude/scripts/conductor.sh --auto                # Autonomous mode
bash .claude/scripts/conductor.sh --auto --budget 5     # Cap at $5
bash .claude/scripts/conductor.sh --check               # Quick status
bash .claude/scripts/conductor.sh --serve               # Web UI on port 7777
bash .claude/scripts/conductor.sh --reset               # Reset state
```

### How It Works

1. Reads `TODO.md` for the next task
2. Reads `JOURNAL.md` for context from the previous session
3. Spawns `claude -p "<prompt>"` with the task and context
4. Monitors the exit code
5. If completed: move to next task
6. If rate limited: exponential backoff (5min → 10min → 20min; 3 limits → stop)
7. If timeout/token limit: restart in 10 seconds
8. If error: retry in 30 seconds
9. Tracks total cost and enforces budget
10. Generates `conductor.html` dashboard (auto-refreshes every 15 seconds)

### Monitoring

The conductor generates `.claude/reports/conductor.html` — a self-contained dashboard showing session count, cost, current task, failure count, and session history. With `--serve`, it starts a web server on port 7777 that you can open from any browser, including your phone on the same network.

### Safety

- **Pidfile lock** prevents two conductors from running simultaneously
- **Budget cap** stops before spending too much
- **Consecutive failure limit** (default 3) stops if something is fundamentally broken
- **Session limit** (default 50) prevents runaway loops
- The conductor is deliberately simple (bash, not AI) because the supervisor must be deterministic

### Overnight Runs

```bash
# Start before bed:
bash .claude/scripts/conductor.sh --auto --budget 10

# Check from phone:
bash .claude/scripts/conductor.sh --serve
# Open http://<your-ip>:7777 on phone

# Next morning:
bash .claude/scripts/conductor.sh --check
```

---

## 14. The Dashboard & Reports

### /zibe-check (30 seconds, stdout)

The fastest status view. Prints a compact report to stdout — no files generated. Shows health signal, recent commits, test status, concerns, and next task. Use anytime: between meetings, from your phone, 2am curiosity.

### /zibe-health (comprehensive, stdout)

Full health check: git status, test count/pass/fail/time, build status, lint errors, typecheck, dependency audit, ratchet state, TODO status. Use at session start or before a commit.

### /zibe-digest (daily, text file)

Generates `.claude/reports/digest-YYYY-MM-DD.md` and prints to stdout. Includes deltas vs yesterday (reads previous digest for comparison). Health signal, tests, build, lint, git activity, ratchet progress, tasks, warnings, plain-English summary. Under 60 lines. Readable via `cat`.

### /zibe-dashboard (visual, HTML file)

Generates `.claude/reports/dashboard.html` — a single self-contained HTML file with Chart.js visualizations. Sections: health traffic light, test pass/fail donut, ratchet staircase chart, task progress, git activity, warnings. Dark mode, mobile-friendly, under 50KB. Just open the file — no server needed.

### /zibe-walkthrough (project tour, HTML file)

Generates `.claude/reports/walkthrough.html` — an interactive guided tour of the project. Includes: overview, color-coded file tree, commit-by-commit change slides, architecture walkthrough, test coverage, ratchet history, known issues, and how to continue. Use for onboarding, or when returning after days away.

---

## 15. Session Lifecycle

Every Claude Code session follows this lifecycle. The hooks automate most of it.

### Session Start (automatic)

The `session-start.sh` hook fires on startup, resume, compact, and clear. It:
1. Injects environment variables via `CLAUDE_ENV_FILE`
2. Reports project, branch, modified file count
3. Fixes hook permissions if needed
4. Warns if jq is missing
5. Prunes logs older than 7 days
6. Loads and displays the previous JOURNAL.md
7. Reports ratchet state and remaining TODO count

### During Work

The `stop-journal.sh` hook fires at the end of every Claude turn. It writes `.claude/JOURNAL.md` with current timestamp, branch, uncommitted count, last 3 commits, test status, and next TODO items. This means if the session dies for any reason, the journal is at most ONE TURN old.

### Before Compaction

When context is compressed (manually via `/compact` or automatically), the `post-compact-handoff.sh` hook writes `.claude/HANDOFF.md` with recovery instructions. The next SessionStart loads this file.

### Session End

Run `/zibe-retro` to analyze the session. The meta-ratchet skill reads the journal and git history, identifies failures, proposes rules to EVOLUTION.md, and scores the session.

If proof-sensitive work was done:
```
/zibe-prove          # verify claims
/zibe-sync-todo      # check off proven items
```

### Recommended Pattern

```
Session start → (hook loads context automatically)
/zibe-check                    # quick orientation
... do work ...
/zibe-prove                    # if proof items exist
/zibe-sync-todo                # sync proof to TODO
/zibe-retro                    # analyze session
```

---

## 16. Daily Workflow

### Morning

```
cd /your/project
claude
/zibe-check                    # 30-second orientation
```

Look at: health signal, test status, next TODO item. If tests are failing from last night's conductor run, fix them first.

### Working

For a new feature:
```
/zibe-implement [description]  # TDD cycle with subagent isolation
```

For complex work:
```
/self-plan [description]       # think before building
# review .claude/PLAN.md
/zibe-implement [description]  # then build
```

For quick tasks:
```
/zibe-todo fix phase, fix the login bug, update error messages
# ... do the work ...
```

For improvements:
```
/zibe-ratchet                  # follows program.md directions
```

### During the Day

```
/zibe-check                    # anytime spot check
/review                        # native code review (not zibe)
```

### End of Day

```
/zibe-prove                    # verify any proof items
/zibe-sync-todo                # sync proofs to TODO
/zibe-retro                    # session retrospective
/zibe-digest                   # daily report
```

### Overnight

```bash
# In your terminal (NOT inside Claude Code):
bash .claude/scripts/conductor.sh --auto --budget 5
```

### Weekly

```
/assumption-audit              # challenge your assumptions
/scout                         # check for Claude Code updates
/zibe-dashboard                # visual health report
/zibe-walkthrough              # updated project tour
```

Review `.claude/EVOLUTION.md` for proposed rules. Promote good ones to CLAUDE.md, reject bad ones with a note.

---

## 17. Evolution & Self-Improvement

### How It Works

The meta-ratchet (triggered by `/zibe-retro`) analyzes session failures and proposes rule changes. It writes proposals to `.claude/EVOLUTION.md`. The human reviews and decides what gets promoted.

This is critical: **the system proposes, the human decides.** Instructions are too important for unsupervised self-modification.

### The Pipeline

```
Failure observed
    → meta-ratchet identifies pattern
    → formulates candidate rule (specific, actionable, one sentence)
    → checks if rule already exists
    → writes proposal to EVOLUTION.md
    → human reviews
    → promote to CLAUDE.md, reject with reason, or retire old rules
```

### Good Rules vs Bad Rules

Every rule must trace to a specific observed failure.

| Bad Rule | Good Rule |
|----------|-----------|
| "Always write good tests" | "Do not edit non-test source without a recent RED signal" |
| "Be careful with files" | "NEVER use exit 1 to block in hooks — use JSON + exit 0" |
| "Stay focused" | "Do not let unrelated failing tests redefine the current task" |

### Instruction Budget

CLAUDE.md should stay under 25 rules. Beyond ~150-200 instructions, Claude starts ignoring them. Every addition must justify its cost by preventing a named failure. When adding a rule, look for one to retire.

### Three Levels of Self-Correction

| Level | Catches | Scope | Tool |
|-------|---------|-------|------|
| Meta-ratchet | Rule-level failures ("Claude skipped TDD") | Individual instructions | `/zibe-retro` |
| Self-critic | Plan-level failures ("missing edge case") | Feature design | `self-plan` skill |
| Assumption-audit | Architecture-level failures ("system assumes sessions stay alive") | Entire system | `/assumption-audit` |

---

## 18. Context Management

Claude Code has a finite context window. As it fills, response quality degrades and instructions get ignored.

| Context Usage | Action |
|---------------|--------|
| 0-50% | Work freely |
| 50% | Run `/compact` preserving: modified files, test status, branch, current task |
| 70% | Commit work, write handoff notes, start a new session |
| 90%+ | **STOP.** Run `/clear` or start a new session. Quality is already degraded. |

### What Survives Compaction

The `post-compact-handoff.sh` hook writes `.claude/HANDOFF.md` with branch, modified files, recent commits, and resume instructions. The next `SessionStart` loads it.

### What Survives Crashes

The `stop-journal.sh` hook writes `.claude/JOURNAL.md` every turn. If the session crashes, the journal is at most one turn old. The conductor reads it to provide context to the next session.

### The Fresh Context Pattern

For long-running work, deliberately break it into sessions:
1. Plan in Session 1 → write `.claude/PLAN.md`
2. Implement Phase 1 in Session 2 → commit, update TODO.md
3. Implement Phase 2 in Session 3 → commit, update TODO.md
4. Review in Session 4 → `/review`

Each session starts clean with full context budget. State lives in committed files, not in the context window.

---

## 19. Git Workflow

### Branch Naming

```
feat/feature-name
fix/bug-description
refactor/what-changed
test/what-was-tested
docs/what-was-documented
```

### Commit Messages (conventional)

```bash
git commit -m "test: red — login validation tests"
git commit -m "feat: green — login validation implementation"
git commit -m "refactor: extract email validator"
git commit -m "ratchet: reduce bundle size by 12KB"
```

### TDD Commit Cycle

1. `test: red — [what tests expect]` — After writing failing tests
2. `feat: green — [what was implemented]` — After tests pass
3. `refactor: [what was cleaned up]` — After refactoring

### A/B Worktrees (Wigwam Pattern)

When you're unsure which approach is better:

```bash
claude -w approach-a    # Build approach A in its own worktree
claude -w approach-b    # Build approach B in parallel
# Compare metrics, keep the winner
```

### Rules

- NEVER commit to `main` or `master` directly (hooks block force-push)
- NEVER commit `.env`, `.key`, `.pem` files (hooks block staging)
- Run full test suite before PR

---

## 20. Debugging

### Hook Doesn't Block

**Symptom:** Hook runs but the action proceeds.
**Cause:** Using `exit 1` (non-blocking) or wrong JSON format.
**Fix:** All blocking hooks must output `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` and exit 0.
**Test:** `echo '{"tool_input":{"command":"rm -rf /"}}' | bash ~/.claude/hooks/pre-tool-security.sh`

### Stop Hook Infinite Loop

**Symptom:** Claude loops between Stop events until context exhaustion.
**Cause:** Stop hook outputs text → Claude processes → triggers Stop → loop.
**Fix:** Check `stop_hook_active` field in input JSON. Exit immediately if true.

### jq Not Installed

**Symptom:** All hooks silently fail. No security protection.
**Fix:** Install jq. Every Zibe hook checks for jq first and fails closed (blocks everything) if missing.

### Claude Modifies Tests During Implementation

**Symptom:** Tests pass but feature doesn't work correctly.
**Fix:** The `pre-write-guard` hook blocks test file edits unless `CLAUDE_TDD_PHASE=red`. The `SubagentStart` hook sets this only for the `tdd-test-writer` agent.

### Claude Chases Unrelated Failures

**Symptom:** Claude abandons current task to fix a pre-existing test failure.
**Fix:** CLAUDE.md rule #4: "Do not let unrelated failing tests redefine the current task." If Claude keeps getting distracted, use scope-lock: "ONLY work on X. Do NOT touch Y."

### Claude Claims "Fixed" Without Verification

**Symptom:** Claude says "done" but the original bug persists.
**Fix:** Use the proof system. Add `claim-id` and `proof-command` to the TODO item, then `/zibe-prove` before accepting the claim.

### Context Exhaustion

**Symptom:** Responses become vague, instructions ignored, hallucinations.
**Fix:** `/compact` at 50%. Commit + new session at 70%. `/clear` at 90%+.

### Hook Not Executable

**Symptom:** Hook silently doesn't run.
**Fix:** `chmod +x ~/.claude/hooks/*.sh`. The `session-start` hook auto-fixes this on every session start.

### Commands Don't Appear

**Symptom:** `/zibe-*` not in autocomplete.
**Fix:** Restart Claude Code. It discovers commands from `~/.claude/commands/` at startup.

### Recovery

```bash
git checkout -- .                              # Revert all changes
git log --oneline -10 && git reset --hard <hash>  # Nuclear rollback
git checkout HEAD -- .claude/ratchet-state.json    # Fix ratchet state
chmod +x ~/.claude/hooks/*.sh                      # Fix permissions
claude --debug "hooks"                             # Debug hook execution
```

---

## 21. Maintenance

### Weekly

1. **Review EVOLUTION.md** — Promote good rule proposals to CLAUDE.md, reject bad ones with a note, retire rules that aren't preventing failures.

2. **Check instruction budget** — Count rules in CLAUDE.md. Target under 25. If approaching the limit, look for rules to merge or retire.

3. **Run `/scout`** — Check for Claude Code updates. Review proposed feature experiments.

4. **Prune logs** — The `session-start` hook auto-prunes logs older than 7 days, but check disk space if you're generating many reports.

5. **Update program.md** — Move completed ratchet directions to the "Completed" section. Add new directions. Mark exhausted directions.

### Monthly

1. **Run `/assumption-audit`** — Challenge the system's architectural assumptions. Are there new failure modes? New blind spots?

2. **Review model costs** — Check if your model/effort configuration is appropriate. Are you spending opus on tasks that sonnet handles fine?

3. **Update project CLAUDE.md** — Has your stack changed? New test runner? New conventions?

### When Something Goes Wrong

1. Run `/zibe-retro` immediately (while the failure is fresh in context)
2. Read the proposed rules in EVOLUTION.md
3. Decide if a hook would prevent this better than a rule (hooks = 100%, rules = 80%)
4. If the failure is architectural, run `/assumption-audit`

---

## 22. Iteration Advice

### Start Simple

Don't try to use every feature on day one. Layer up:

1. **Week 1:** Install, use `/zibe-check` and `/zibe-health`, do normal work. Get comfortable with the slash commands.

2. **Week 2:** Start using `/zibe-implement` for TDD. Use `/zibe-retro` at session end. Review EVOLUTION.md.

3. **Week 3:** Set up `program.md` and run `/zibe-ratchet` for autonomous improvements. Try the conductor overnight.

4. **Week 4:** Add proof metadata to TODO items. Use `/zibe-prove` and `/zibe-sync-todo`. Run `/assumption-audit`.

### The 80/20 Rule

80% of the value comes from:
- `/zibe-todo` for task capture
- `/zibe-implement` for TDD
- `/zibe-check` for quick status
- The stop-journal hook (crash recovery)
- The pre-tool-security hook (safety)

The other 20% (dashboard, walkthrough, conductor, scout, model enforcement, proofs) adds significant value but only after the basics are solid.

### Common Mistakes

1. **Too many rules too fast.** Start with the 6 prime directives in CLAUDE.md. Add rules only when you observe specific failures. Instructions are scars, not theories.

2. **Skipping `/zibe-retro`.** The retro is how the system learns. Even good sessions have near-misses worth analyzing.

3. **Not using the proof system for important work.** If you wouldn't ship without a human checking it, add a proof. The machine check is faster and more reliable.

4. **Running the conductor without checking TODO.md.** The conductor reads TODO.md for tasks. If TODO.md is empty or stale, the conductor defaults to `/zibe-ratchet`, which may not be what you want.

5. **Fighting Claude on test modifications.** If Claude keeps trying to edit tests, the test is probably wrong. But don't let Claude silently change it — the write-guard hook blocks this. Instead, discuss the test and decide together.

6. **Mega-sessions.** Quality degrades after 50% context usage. Commit frequently. Start new sessions for new tasks. Fresh context is free; stale context is expensive.

### The Ideal Prompt

The best prompts for Zibe are naive:

```
Implement user login with email and password validation.
```

You don't need to say "use TDD" or "write tests first" — the system handles that. You don't need to say "commit your work" — the hooks and workflow enforce it. You provide the *what*. The system provides the *how*.

If you find yourself giving Claude detailed instructions about process, that's a signal that a rule or hook is missing. File it in EVOLUTION.md.
