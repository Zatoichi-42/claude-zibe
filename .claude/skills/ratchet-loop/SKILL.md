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
