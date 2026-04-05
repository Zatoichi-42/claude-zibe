#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/.claude"
TGT="$HOME/.claude"
G='\033[0;32m';Y='\033[1;33m';R='\033[0;31m';NC='\033[0m'
ok(){ echo -e "  ${G}✓${NC} $1"; }
wn(){ echo -e "  ${Y}⚠${NC} $1"; }
fl(){ echo -e "  ${R}✗${NC} $1"; }
[ -d "$SRC" ] || { fl "Cannot find $SRC"; exit 1; }
echo "Installing claude-zibe → ~/.claude/ ..."
if [ -d "$TGT" ]; then
  BK="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backing up → $BK"; cp -r "$TGT" "$BK"; ok "Backup created"
fi
echo "Copying files..."
cp -r "$SRC"/* "$TGT/" 2>/dev/null||true
cp -r "$SRC"/.[!.]* "$TGT/" 2>/dev/null||true
mkdir -p "$TGT"/{logs,reports,worktrees}
echo "Setting permissions..."
find "$TGT/hooks" -name "*.sh" -exec chmod +x {} \; 2>/dev/null||true
find "$TGT/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null||true
echo "Checking requirements..."
command -v jq &>/dev/null && ok "jq" || fl "jq MISSING (brew install jq)"
command -v git &>/dev/null && ok "git" || fl "git MISSING"
command -v claude &>/dev/null && ok "claude" || wn "claude CLI not in PATH"
echo "Verifying..."
M=0
for f in CLAUDE.md settings.json model-config.json EVOLUTION.md OPEN-QUESTIONS.md; do
  [ -f "$TGT/$f" ] && ok "$f" || { fl "$f"; M=1; }
done
for d in commands skills agents hooks rules docs scripts; do
  [ -d "$TGT/$d" ] && ok "$d/" || { fl "$d/"; M=1; }
done
echo ""
[ "$M" -eq 0 ] && echo -e "${G}✓ Install complete!${NC}" || echo -e "${Y}⚠ Some files missing${NC}"
