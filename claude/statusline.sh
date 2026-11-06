#!/bin/bash
# Claude Code statusline — two-line display
# Line 1: hostname:working_dir -> date/time  (hostname in blue)
# Line 2: model + token counts (in/out) + turn count + session cost + context %
#
# Color thresholds:
#   Turns:   yellow >=50 | red >=80
#   Cost:    yellow >=$10.00 | red >=$30.00
#   Context: yellow >=60% | red >=80%
#
# Prerequisites: bash, jq, bc
# Install: personal-files/install.sh links this to ~/.claude/statusline.sh and wires it into settings.json
#
# Receives Claude Code telemetry JSON on stdin.
# Note: turn count is grep-based (approximate, not exact).

# Check prerequisites
for cmd in jq bc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Claude Code statusline: missing prerequisite '$cmd' (brew install $cmd)"
    exit 1
  fi
done

input=$(cat)

# ANSI color codes
RESET='\033[0m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'

# --- Line 1: blue hostname:working_dir -> datetime ---
HOST=$(hostname -s)
DATETIME=$(date "+%a %b %d  %H:%M:%S")
RAW_DIR=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$RAW_DIR" ] && RAW_DIR="$PWD"
REL_DIR="${RAW_DIR/#$HOME/~}"
LINE1=$(printf "${BLUE}${HOST}${RESET}:${REL_DIR} -> ${DATETIME}")

# --- Line 2: tokens + cost + context ---
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // ""')
IN_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOK=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
MODEL=$(echo "$input" | jq -r '.model.display_name // empty')

# Approximate turn count from transcript (counts assistant messages)
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  TURNS=$(grep -c '"type":"assistant"' "$TRANSCRIPT" 2>/dev/null || echo 0)
else
  TURNS=0
fi

COST_FMT=$(printf "%.3f" "$COST" 2>/dev/null || echo "$COST")

# Format token counts with k suffix at >=1000
fmt_k() {
  local n=$1
  if [ "$n" -ge 1000 ] 2>/dev/null; then
    printf "%.1fk" "$(echo "scale=1; $n / 1000" | bc 2>/dev/null || echo "$n")"
  else
    echo "$n"
  fi
}

IN_FMT=$(fmt_k "$IN_TOK")
OUT_FMT=$(fmt_k "$OUT_TOK")

# Color-code turns: yellow >=50, red >=80
TURNS_COLOR=""
TURNS_RESET=""
if [ "$TURNS" -ge 80 ] 2>/dev/null; then
  TURNS_COLOR="$RED"
  TURNS_RESET="$RESET"
elif [ "$TURNS" -ge 50 ] 2>/dev/null; then
  TURNS_COLOR="$YELLOW"
  TURNS_RESET="$RESET"
fi

# Color-code cost: yellow >=$10.00, red >=$30.00
COST_COLOR=""
COST_RESET=""
COST_CMP=$(echo "$COST >= 30.0" | bc 2>/dev/null)
if [ "${COST_CMP}" = "1" ]; then
  COST_COLOR="$RED"
  COST_RESET="$RESET"
else
  COST_CMP=$(echo "$COST >= 10.0" | bc 2>/dev/null)
  if [ "${COST_CMP}" = "1" ]; then
    COST_COLOR="$YELLOW"
    COST_RESET="$RESET"
  fi
fi

# Color-code context: yellow >=60%, red >=80%
CTX_COLOR=""
CTX_RESET=""
if [ "$PCT" -ge 80 ] 2>/dev/null; then
  CTX_COLOR="$RED"
  CTX_RESET="$RESET"
elif [ "$PCT" -ge 60 ] 2>/dev/null; then
  CTX_COLOR="$YELLOW"
  CTX_RESET="$RESET"
fi

printf "%s\n" "$LINE1"
MODEL_PREFIX=""
[ -n "$MODEL" ] && MODEL_PREFIX="${MODEL} | "
printf "${MODEL_PREFIX}in:${IN_FMT} out:${OUT_FMT} | ${TURNS_COLOR}${TURNS}t${TURNS_RESET} | ${COST_COLOR}\$${COST_FMT}${COST_RESET} | ${CTX_COLOR}ctx:${PCT}%%${CTX_RESET}"
