---
name: assumption-audit
description: >
  Challenge architectural assumptions. Find blind spots.
  Trigger: "what are we missing", "blind spots", "challenge architecture".
argument-hint: "[optional: system to audit]"
disable-model-invocation: true
context: fork
agent: self-critic
allowed-tools: Read, Bash, Glob, Grep
---

# Assumption Audit
Target: $ARGUMENTS (or entire system)
1. LIST assumptions from CLAUDE.md, settings, skills, agents
2. INVERT each: if FALSE → consequence → gap → fix
3. CATEGORIZE: topology/dependency/lifecycle/observability/human/scale
4. PRIORITIZE: likelihood × severity (≥15 critical, ≥9 important)
5. PROPOSE fixes → EVOLUTION.md
6. Write questions → OPEN-QUESTIONS.md
