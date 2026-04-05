#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$SCRIPT_DIR/project-template"
[ -d "$TPL" ] || { echo "Cannot find $TPL"; exit 1; }
echo "Scaffolding project files in $(pwd) ..."
ci(){ local s="$1" d="$2"; mkdir -p "$(dirname "$d")"
  [ -f "$d" ] && echo "  ⏭ $d (exists)" || { cp "$s" "$d"; echo "  ✓ $d"; }; }
ci "$TPL/CLAUDE.md" "CLAUDE.md"
ci "$TPL/TODO.md" "TODO.md"
ci "$TPL/TODO-prompt.md" "TODO-prompt.md"
ci "$TPL/program.md" "program.md"
ci "$TPL/.claude/settings.json" ".claude/settings.json"
mkdir -p .claude/logs .claude/reports
echo "Done. Edit CLAUDE.md, TODO.md, program.md for your project."
