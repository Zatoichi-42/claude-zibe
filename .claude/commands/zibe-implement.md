---
name: zibe-implement
description: Build a feature using strict TDD. Delegates to tdd-loop skill.
argument-hint: "[feature description]"
---
# /zibe-implement — TDD Feature Build

## Process
1. Load the tdd-loop skill
2. Plan testable behaviors from: $ARGUMENTS
3. Delegate RED to tdd-test-writer agent
4. Confirm tests fail
5. Delegate GREEN to tdd-implementer agent
6. Confirm tests pass
7. Refactor in main context
8. Full verification (tests + types + lint)
9. Commit with conventional message

If description is vague, ask: input? output? error behavior? existing patterns?
