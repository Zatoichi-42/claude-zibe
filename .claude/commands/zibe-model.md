---
name: zibe-model
description: Override model across agents, skills, and tier config. Usage: /zibe-model default|sonnet|opus
argument-hint: "default|sonnet|opus"
---
# /zibe-model — Model Override

## Usage
- `/zibe-model default` — restore model-config.defaults.json settings
- `/zibe-model sonnet` — force sonnet across all enforceable surfaces
- `/zibe-model opus` — force opus across all enforceable surfaces

## Process
1. Read $ARGUMENTS (default, sonnet, or opus)
2. If "default": copy `.claude/model-config.defaults.json` → `.claude/model-config.json`
   and reset `.claude/model-enforcement.state.json` to `{"model":null}`
3. If "sonnet" or "opus":
   a. Update `.claude/model-enforcement.state.json` with `{"model":"<value>","timestamp":"<now>"}`
   b. Update `.claude/model-config.json` tiers to use the specified model
   c. Note: hooks and rules do NOT have model settings (report as n/a)
4. Confirm the change

## Enforceable surfaces
- Agent frontmatter `model:` field
- Skill content (effort tiers reference model)
- `.claude/model-config.json` tier definitions
- NOT enforceable: hooks, rules (report n/a)
