#!/usr/bin/env bash
set -euo pipefail

# Shared notification style: palette, meter, rows, notify-send wrapper.
# Same look as ~/.local/bin/claude-credit-check.
source "$HOME/.local/lib/notify-style.sh"
n_prepare_env

BAT="${BATTERY_CHECK_BAT:-BAT0}"
# Overridable so the notification can be checked against a fake sysfs tree
SYS="${BATTERY_CHECK_SYS:-/sys/class/power_supply/$BAT}"

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

[[ "$CURRENT_RANGE" == "$LAST_RANGE" ]] && exit 0

# The icon follows the band, so the card is readable before the text is: a full
# green cell while it only needs watching, an empty red one when it is nearly out.
case "$CURRENT_URGENCY" in
  critical) ICON="battery-critical"; GLYPH=$'' ; ACCENT="$N_RED" ;;    # nf-fa-battery_empty
  normal)   ICON="battery-low";      GLYPH=$'' ; ACCENT="$N_AMBER" ;;  # nf-fa-battery_half
  *)        ICON="battery-ok";       GLYPH=$'' ; ACCENT="$N_GREEN" ;;  # nf-fa-battery_full
esac

# Time left, from the discharge rate the kernel reports. power_now is 0 right after
# a state change, and then there is nothing to estimate from.
REMAINING=""
if [[ -r "$SYS/energy_now" && -r "$SYS/power_now" ]]; then
  ENERGY=$(<"$SYS/energy_now")
  POWER=$(<"$SYS/power_now")
  if (( POWER > 0 )); then
    MINUTES=$(( ENERGY * 60 / POWER ))
    if (( MINUTES >= 60 )); then
      REMAINING=$(printf '%dh%02dm' $(( MINUTES / 60 )) $(( MINUTES % 60 )))
    else
      REMAINING=$(printf '%dm' "$MINUTES")
    fi
    REMAINING+=$(printf ' at %d.%dW' $(( POWER / 1000000 )) $(( POWER % 1000000 / 100000 )))
  fi
fi

# Row 1 — the band that was crossed. Row 2 — the meter and the estimate. Both stay
# short: dunst wraps a body at the max width in ~/.config/dunst/dunstrc.
BODY=$(n_body \
  "$(n_head_row "$GLYPH" "$ACCENT" "$CURRENT_LABEL")" \
  "$(n_meter_row Charge "$CAPACITY" "$REMAINING")")

# Sticky once it is critical: it has to survive being missed. The stack tag replaces
# the previous band instead of leaving a trail down the screen.
TIMEOUT=15000
[[ "$CURRENT_URGENCY" == "critical" ]] && TIMEOUT=0

n_notify "Battery" "$ICON" "$CURRENT_URGENCY" "$TIMEOUT" "battery" \
  "$(printf '%d%% remaining' "$CAPACITY")" \
  "$BODY"

echo "$CURRENT_RANGE" > "$STATE_FILE"
