---
name: zibe-prove
description: Run proof commands for claim-id items in TODO.md. Write results to proof-log.json.
---
# /zibe-prove — Execute Proof Commands

## Process
1. Read root `TODO.md`
2. Find all unchecked items (`- [ ]`) that have `claim-id:` and `proof-command:` metadata
3. For each claim:
   a. Run the `proof-command`
   b. Check exit code (proof-assert: command_exit_zero)
   c. If `proof-artifact` specified, verify the file exists
   d. If `proof-assert: artifact_json_path_exists=<path>` specified, verify the JSON path
   e. Record result in `.claude/proof-log.json`
4. Print summary: passed/failed/skipped claims

## proof-log.json format
```json
{
  "version": "1.0",
  "last_run": "<timestamp>",
  "claims": [
    {
      "claim_id": "validation.transport_status",
      "status": "pass|fail|skip",
      "proof_command": "...",
      "exit_code": 0,
      "assertions": [{"assert": "...", "result": "pass|fail"}],
      "timestamp": "..."
    }
  ]
}
```

## Important
- Do NOT mark TODO items as complete here. Use /zibe-sync-todo for that.
- Do NOT use completion language until proof passes.
