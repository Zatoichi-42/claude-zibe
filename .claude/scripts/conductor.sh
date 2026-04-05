#!/usr/bin/env bash
set -euo pipefail
# Conductor — External session controller. See MANUAL.md §4.
PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE="$PROJ/.claude/conductor-state.json"
LOG="$PROJ/.claude/logs/conductor.log"
PID="$PROJ/.claude/conductor.pid"
PORT="${CONDUCTOR_PORT:-7777}"
MAX_BUDGET=10; MAX_FAILS=3; MAX_SESSIONS=50; TIMEOUT=600; TURNS=25; WAIT=300
log(){ echo -e "[$(date +%H:%M:%S)] $1" | tee -a "$LOG" 2>/dev/null; }
init(){ mkdir -p "$(dirname "$STATE")" "$(dirname "$LOG")" "$PROJ/.claude/reports"
  [ -f "$STATE" ] || echo '{"status":"idle","total_sessions":0,"total_cost_usd":0,"consecutive_failures":0,"last_exit_reason":null,"current_task":null,"history":[]}' > "$STATE"; }
rs(){ jq -r "$1" "$STATE" 2>/dev/null||echo "0"; }
us(){ local t=$(mktemp); jq "$1" "$STATE">"$t" 2>/dev/null&&mv "$t" "$STATE"; }
get_task(){ local t=""; [ -f "$PROJ/TODO.md" ] && t=$(grep -m1 '^\- \[ \]' "$PROJ/TODO.md" 2>/dev/null|sed 's/^- \[ \] //'||true)
  [ -z "$t" ] && t="Run /zibe-ratchet following program.md."; echo "$t"; }
run_session(){ local task="$1" ec=0; log "Session #$(( $(rs '.total_sessions') + 1 )): ${task:0:60}..."
  us ".status=\"running\"|.current_task=\"$(echo "$task"|head -c 100|sed 's/"/\\"/g')\""
  local rf=$(mktemp) ctx=""
  [ -f "$PROJ/.claude/JOURNAL.md" ] && ctx="PREVIOUS:\n$(cat "$PROJ/.claude/JOURNAL.md")\n\n"
  timeout "$TIMEOUT" claude -p "${ctx}Read CLAUDE.md. TASK: ${task}\nBEGIN." --output-format json --max-turns "$TURNS" \
    --permission-mode auto --allowedTools "Read,Write,Edit,MultiEdit,Bash,Glob,Grep,Agent" >"$rf" 2>>"$LOG" || ec=$?
  local cost=$(jq -r '.total_cost_usd//0' "$rf" 2>/dev/null||echo 0) reason="completed"
  [ "$ec" -eq 124 ] && reason="timeout"
  [ "$(jq -r '.is_error//false' "$rf" 2>/dev/null)" = "true" ] && reason="error"
  local cf=$(rs '.consecutive_failures'); [ "$reason" = "completed" ] && cf=0 || cf=$((cf+1))
  us ".total_sessions+=1|.total_cost_usd=(.total_cost_usd+$cost)|.consecutive_failures=$cf|.last_exit_reason=\"$reason\""
  rm -f "$rf"; echo "$reason"; }
auto_loop(){ [ -f "$PID" ] && kill -0 "$(cat "$PID")" 2>/dev/null && { log "Already running."; exit 1; }
  echo $$>"$PID"; trap 'rm -f "$PID"' EXIT INT TERM; log "=== AUTO MODE === Budget: \$$MAX_BUDGET"
  us '.status="auto"'; local s=0 rl=0
  while true; do
    local c=$(rs '.total_cost_usd') cf=$(rs '.consecutive_failures')
    awk "BEGIN{exit !($c>=$MAX_BUDGET)}" 2>/dev/null && { log "Budget."; break; }
    [ "$cf" -ge "$MAX_FAILS" ] && { log "Failures."; break; }
    [ "$s" -ge "$MAX_SESSIONS" ] && { log "Max sessions."; break; }
    local task=$(get_task); [ -z "$task" ] && { log "No tasks."; break; }
    local r=$(run_session "$task"); s=$((s+1))
    case "$r" in completed)rl=0;sleep 5;; rate_limit)rl=$((rl+1));[ "$rl" -ge 3 ]&&break;sleep $((WAIT*(2**(rl-1))));; timeout)rl=0;sleep 10;; *)rl=0;sleep 30;; esac
  done; us '.status="idle"'; log "Done: $(rs '.total_sessions') sessions \$$(rs '.total_cost_usd')"; }
for i in "$@"; do case $i in --budget)shift;MAX_BUDGET="${1:-10}";shift 2>/dev/null||true;; esac; done
cd "$PROJ"; init
case "${1:-}" in --auto)auto_loop;; --check)echo "Sessions:$(rs '.total_sessions') Cost:\$$(rs '.total_cost_usd') Fails:$(rs '.consecutive_failures')";;
  --serve)cd "$PROJ/.claude/reports";python3 -m http.server "$PORT" 2>/dev/null||echo "No python";; --reset)rm -f "$STATE";init;;
  *)echo "Usage: conductor.sh [--auto [--budget N]] [--check] [--serve] [--reset]";; esac
