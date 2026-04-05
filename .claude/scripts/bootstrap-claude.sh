#!/usr/bin/env bash
set -euo pipefail
# Project bootstrap verification — checks global + project, never recreates global locally.
echo "Verifying environment..."
G='\033[0;32m';Y='\033[1;33m';R='\033[0;31m';NC='\033[0m'
ok(){ echo -e "  ${G}✓${NC} $1"; }; wn(){ echo -e "  ${Y}⚠${NC} $1"; }; fl(){ echo -e "  ${R}✗${NC} $1"; }

echo "── Global (~/.claude/) ──"
for f in CLAUDE.md settings.json model-config.json; do
  [ -f "$HOME/.claude/$f" ] && ok "~/.claude/$f" || fl "~/.claude/$f MISSING — run install.sh"
done
for d in commands skills agents hooks rules docs scripts; do
  [ -d "$HOME/.claude/$d" ] && ok "~/.claude/$d/" || fl "~/.claude/$d/ MISSING — run install.sh"
done

echo "── Hook permissions ──"
for h in "$HOME/.claude/hooks/"*.sh; do
  [ -f "$h" ] && [ ! -x "$h" ] && chmod +x "$h" && wn "Fixed: $(basename "$h")"
  [ -f "$h" ] && [ -x "$h" ] && ok "$(basename "$h")"
done

echo "── Project files ──"
for f in CLAUDE.md TODO.md program.md; do
  [ -f "$f" ] && ok "$f" || wn "$f missing — run project-install.sh"
done
[ -f ".claude/settings.json" ] && ok ".claude/settings.json" || wn ".claude/settings.json missing"

echo "── Project dirs (local only: logs, reports) ──"
for d in logs reports; do
  mkdir -p ".claude/$d" 2>/dev/null
  ok ".claude/$d/"
done

echo "── Tools ──"
command -v jq &>/dev/null && ok "jq $(jq --version 2>&1)" || fl "jq MISSING (required)"
command -v git &>/dev/null && ok "git" || fl "git MISSING"
[ -d .git ] && ok "git initialized ($(git branch --show-current 2>/dev/null || echo '?'))" || wn "No .git"
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] && wn "On $BRANCH — use a feature branch"

echo "── State ──"
for f in ratchet-state.json proof-log.json; do
  [ -f ".claude/$f" ] && ok ".claude/$f" || { wn ".claude/$f initializing"; }
done
[ -f ".claude/ratchet-state.json" ] || echo '{"version":"1.0","experiment_count":0,"consecutive_failures":0,"baseline_metrics":{},"experiments":[],"kept_improvements":[]}' > .claude/ratchet-state.json
[ -f ".claude/proof-log.json" ] || echo '{"version":"1.0","claims":[],"last_run":""}' > .claude/proof-log.json

echo "Done."
