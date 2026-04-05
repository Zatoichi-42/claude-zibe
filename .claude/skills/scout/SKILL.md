---
name: scout
description: >
  Scan Claude Code changelog for new features. Propose A/B tests.
  Trigger: "/scout", "check for updates", "new features", "what's new".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
effort: low
---

# Scout — Release Scanner

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
