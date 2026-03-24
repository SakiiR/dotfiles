#!/usr/bin/env bash
set -euo pipefail

BAT="BAT0"
SYS="/sys/class/power_supply/$BAT"

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/battery-notify"
STATE_FILE="$CACHE/last_range"

CAPACITY=$(<"$SYS/capacity")
STATUS=$(<"$SYS/status")

# Reset cache when charging
if [[ "$STATUS" == "Charging" ]]; then
  rm -f "$STATE_FILE"
  exit 0
fi

[[ "$STATUS" == "Discharging" ]] || exit 0

mkdir -p "$CACHE"

# Format: min|max|label|urgency
RANGES=(
  "41|50|Battery above 40%|low"
  "31|40|Battery below 40%|normal"
  "21|30|Battery below 30%|normal"
  "11|20|Battery low|critical"
  "6|10|Battery very low|critical"
  "0|5|Battery critically low|critical"
)

CURRENT_RANGE=""
CURRENT_LABEL=""
CURRENT_URGENCY=""

for r in "${RANGES[@]}"; do
  IFS='|' read -r MIN MAX LABEL URGENCY <<< "$r"
  if (( CAPACITY >= MIN && CAPACITY <= MAX )); then
    CURRENT_RANGE="$MIN-$MAX"
    CURRENT_LABEL="$LABEL"
    CURRENT_URGENCY="$URGENCY"
    break
  fi
done

[[ -z "$CURRENT_RANGE" ]] && exit 0

LAST_RANGE=""
[[ -f "$STATE_FILE" ]] && LAST_RANGE=$(<"$STATE_FILE")

if [[ "$CURRENT_RANGE" != "$LAST_RANGE" ]]; then
  notify-send -u "$CURRENT_URGENCY" \
    "Battery Alert" \
    "$CURRENT_LABEL ($CAPACITY%)"

  echo "$CURRENT_RANGE" > "$STATE_FILE"
fi

