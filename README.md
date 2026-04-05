# claude-zibe — Claude Code Global Bootstrap

Self-moderating, self-healing development environment for Claude Code.
Installs to `~/.claude/` — applies to every project under `~`.

## Install
```bash
git clone https://github.com/Zatoichi-42/claude-zibe.git
cd claude-zibe
bash install.sh            # deploy to ~/.claude/
cd /your/project
bash project-install.sh    # scaffold project files
claude
/zibe-check
```

## Commands (all /zibe- prefixed)
| Command | Purpose |
|---------|---------|
| /zibe-todo | Quick TODO capture with optional proof metadata |
| /zibe-implement | TDD feature build (delegates to tdd-loop skill) |
| /zibe-ratchet | Autonomous improvement loop |
| /zibe-bootstrap | Init/verify project environment |
| /zibe-health | Comprehensive project health check |
| /zibe-check | 30-second spot check (stdout only) |
| /zibe-digest | Daily plain-text report |
| /zibe-dashboard | Interactive HTML dashboard |
| /zibe-walkthrough | Interactive project tour |
| /zibe-retro | Session retrospective |
| /zibe-prove | Run proof commands for claim verification |
| /zibe-sync-todo | Sync proof-log results back to TODO.md |
| /zibe-model | Override model (default/sonnet/opus) |
| /zibe-effort | Override effort (default/low/high) |
| /zibe-enforcement | List current enforcement state |

Native `/review` and `/simplify` are deliberately NOT overridden.

See `.claude/docs/MANUAL.md` for full documentation. 