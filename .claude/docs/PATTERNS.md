# Patterns & Anti-Patterns
## Use
- Error String Anchor: exact error → test → RED → fix → GREEN
- Real Entrypoint: CLI bugs → test the binary
- Anti-Derailment: unrelated failures → note, don't chase
- A/B Worktree: `claude -w approach-a` vs `claude -w approach-b`
- Proof Before Commit: /zibe-prove before completion language
## Avoid
- Kitchen Sink CLAUDE.md (>25 rules = ignored)
- Silent Failure (catch(e){})
- Multi-Change Experiment
- Exit 1 for Blocking (use JSON + exit 0)
- Test-After-the-Fact
- Premature Abstraction
