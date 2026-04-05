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
