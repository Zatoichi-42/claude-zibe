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
