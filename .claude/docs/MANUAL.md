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
