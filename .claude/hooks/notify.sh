#!/usr/bin/env bash
command -v osascript &>/dev/null && osascript -e 'display notification "Claude Code needs attention" with title "Claude Code"' 2>/dev/null||true
command -v notify-send &>/dev/null && notify-send "Claude Code" "Needs attention" 2>/dev/null||true
exit 0
