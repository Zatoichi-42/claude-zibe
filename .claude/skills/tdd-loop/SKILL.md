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
