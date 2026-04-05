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
