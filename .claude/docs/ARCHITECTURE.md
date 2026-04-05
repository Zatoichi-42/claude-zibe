# Architecture & Design Decisions

## Key Decisions
1. Skills vs CLAUDE.md — universal rules in CLAUDE.md, specialized in skills
2. Subagents for context isolation — TDD requires separate windows
3. Git as memory — state persistence, undo, branching
4. Hooks are deterministic, CLAUDE.md is advisory — ~80% vs 100%
5. Ratchet never goes backward — score only increases
6. One change per experiment — atomic attribution
7. Instructions are scars, not theories — trace to observed failures
8. Continuous journaling — Stop hook writes every turn, survives crashes
9. External conductor — bash script supervisor, deterministic, re-entrant
10. Three levels of self-correction: meta-ratchet (rules), self-critic (plans), assumption-audit (architecture)
11. Model/effort enforcement — configurable via /zibe-model, /zibe-effort
12. Proof flow — machine-checkable claims before completion language
13. There are no edge cases, only certainties — fail CLOSED not open

See full version in repo: docs/ARCHITECTURE.md
