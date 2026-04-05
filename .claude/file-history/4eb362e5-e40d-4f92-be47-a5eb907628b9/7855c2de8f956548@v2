---
name: TDD parallel agent test conflict
description: Never spawn multiple test-writer agents in one RED phase — they conflict on shared types
type: feedback
---

Never split a single RED phase across multiple tdd-test-writer agents, even for speed.

**Why:** Two parallel agents independently decided how a shared type (`ForwardOutcome`) should behave when `data_status="ok"` and `forward_return=None`. Agent 1 added a strict validator test; Agent 2 constructed that combination freely. Both were consistent with their individual context but contradicted each other. The result was a test conflict that required user intervention to resolve.

**How to apply:**

- One tdd-test-writer agent per RED phase, always. No parallel test writers for a single implementation slice.
- Shared types (models used by multiple modules) must have all their tests written by the same agent in the same context.
- Every test-writer delegation prompt must end with: "Write EXACTLY the tests listed. Nothing else. The list is a ceiling, not a floor."
- The "include edge cases" instruction in tdd-test-writer.md was the root cause — it was removed and replaced with the ceiling rule.
