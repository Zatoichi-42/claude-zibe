---
name: zibe-sync-todo
description: Sync proof-log.json results back to TODO.md. Check off proven items.
---
# /zibe-sync-todo — Sync Proof Results to TODO

## Process
1. Read `.claude/proof-log.json`
2. Read root `TODO.md`
3. For each claim in proof-log with status "pass":
   a. Find the matching `- [ ]` item in TODO.md by its `claim-id:`
   b. Change `- [ ]` to `- [x]`
4. Write updated TODO.md
5. Report: N items checked off, M items still failing, K items not yet proven
