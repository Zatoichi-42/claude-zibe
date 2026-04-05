---
name: zibe-todo
description: Quick TODO capture. Appends a phase heading and checklist items to root TODO.md.
argument-hint: "phase name, item 1, item 2, item 3"
---
# /zibe-todo — Quick TODO Capture

Parse the arguments as: first segment is the phase name, remaining segments are checklist items (comma-separated).

## Process
1. Parse $ARGUMENTS: first comma-delimited segment = phase heading, rest = items
2. Open the root `TODO.md` file (create if missing)
3. Find the `## TODO LIST` section (create if missing)
4. Append under it:
   ```
   ## <phase name>
   - [ ] <item 1>
   - [ ] <item 2>
   - [ ] <item 3>
   ```
5. Confirm what was added

## Example
`/zibe-todo API hardening, add retry budget, add timeout handling, add structured diagnostics`

Appends:
```md
## API hardening
- [ ] add retry budget
- [ ] add timeout handling
- [ ] add structured diagnostics
```

## Advanced
For proof-sensitive items, the human can manually add under each item:
- `claim-id:` — stable identifier
- `proof-command:` — command to verify
- `proof-artifact:` — file to check
- `proof-assert:` — machine-checkable condition

Then use `/zibe-prove` and `/zibe-sync-todo`.
