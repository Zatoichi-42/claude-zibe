---
name: zibe-effort
description: Override effort across skills and tier config. Usage: /zibe-effort default|low|high
argument-hint: "default|low|high"
---
# /zibe-effort — Effort Override

## Usage
- `/zibe-effort default` — restore defaults
- `/zibe-effort low` — force low effort across enforceable surfaces
- `/zibe-effort high` — force high effort across enforceable surfaces

## Process
1. If "default": reset `.claude/model-enforcement.state.json` effort to null
2. Otherwise: set effort in state file, update model-config.json tiers
3. Confirm the change
