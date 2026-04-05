---
name: zibe-enforcement
description: List current model and effort enforcement state by scope and file.
---
# /zibe-enforcement — Show Enforcement State

## Process
1. Read `.claude/model-enforcement.state.json` for active overrides
2. Read `.claude/model-config.json` for tier definitions
3. List each enforcement surface:
   - Agents: for each `.claude/agents/*.md`, show model from frontmatter
   - Skills: for each skill, show effort from frontmatter
   - Tier config: show model-config.json tiers
   - Hooks: report "n/a" (no native model setting)
   - Rules: report "n/a" (no native model setting)
4. Show active override if any, or "using defaults"
