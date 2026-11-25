#!/bin/bash

# Shared notification style: palette, rows, notify-send wrapper.
source "$HOME/.local/lib/notify-style.sh"
n_prepare_env
STARTED_AT=$SECONDS

usage() {
    echo "Usage: ${0##*/} [--delay DURATION]" >&2
    echo "  --delay DURATION  wait before moving windows, e.g. 90, 30s, 1m, 1h2m3s" >&2
}

# Convert a duration such as 90, 30s, 1m or 1h2m3s to a number of seconds.
parse_duration() {
    local re='^(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s?)?$'
    [[ -n "$1" && "$1" =~ $re ]] || return 1
    echo $(( 10#${BASH_REMATCH[2]:-0} * 3600 + 10#${BASH_REMATCH[4]:-0} * 60 + 10#${BASH_REMATCH[6]:-0} ))
}

DELAY=0  # seconds to wait before Phase 3; set with --delay
while (( $# > 0 )); do
    case "$1" in
        --delay)   value="${2-}"; shift 2 || { usage; exit 2; } ;;
        --delay=*) value="${1#--delay=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *)         echo "Unknown argument: $1" >&2; usage; exit 2 ;;
    esac
    DELAY=$(parse_duration "$value") || { echo "Invalid duration: $value" >&2; usage; exit 2; }
done

# ================================================================
# WORKSPACE ASSIGNMENT TABLE — edit this section to customize
# ================================================================
# KEY:       logical app name (just a label, can be anything)
# PROCESS:   exact process name (comm) used for `pgrep -x` detection
# APP_ID:    niri app_id fragment used to find the window (case-insensitive)
# WORKSPACE: target workspace index (1, 2, 3...)
# COMMANDS:  full path to the executable
#
# PROCESS and APP_ID are separate on purpose: an app rarely names its window
# after its binary (firefox-bin vs firefox-esr, signal-desktop vs signal).
# `ps -eo comm=` gives the PROCESS value, `niri msg -j windows` the APP_ID one.
#
# To add an app:    add its key to all five arrays.
# To remove an app: delete its key from all five arrays.
# To move an app:   change the workspace number in WORKSPACE.
# ================================================================

declare -A PROCESS=(
    [kitty]="kitty"
    [code]="code"
    [firefox]="firefox-bin"
    [keepassxc]="keepassxc"
    [discord]="Discord"
    [signal-desktop]="signal-desktop"
    [spotify]="spotify"
    # [zoom]="zoom"
)

declare -A APP_ID=(
    [kitty]="kitty"
    [code]="code"
    [firefox]="firefox-esr"
    [keepassxc]="keepassxc"
    [discord]="discord"
    [signal-desktop]="signal"
    [spotify]="spotify"
    # [zoom]="zoom"
)

declare -A WORKSPACE=(
    [firefox]="1"
    [kitty]="2"
    [code]="2"
    # [zoom]="3"
    [keepassxc]="3"
    [discord]="4"
    [signal-desktop]="4"
    [spotify]="4"
)

declare -A COMMANDS=(
    [kitty]="$HOME/.local/bin/kitty"
    [code]="/usr/bin/code"
    [firefox]="/usr/bin/firefox-esr"
    [keepassxc]="/usr/bin/keepassxc"
    [discord]="/usr/bin/discord"
    [signal-desktop]="/usr/bin/signal-desktop"
    [spotify]="/snap/bin/spotify"
    # [zoom]="/usr/bin/zoom"
)

# ================================================================
# TIMING
# ================================================================
SPAWN_WAIT_TIMEOUT=30  # max seconds to wait for each process to appear
AFTER_SPAWN_SLEEP=2    # pause after all spawns before waiting for processes
AFTER_WAIT_SLEEP=2     # pause after all processes confirmed before moving
INTER_MOVE_SLEEP=0.2   # pause between each window move (no focus hop to settle)

# ================================================================

log() { echo "[$(date '+%H:%M:%S')] $*"; }

# -x matches the process name exactly. A substring match on the full command
# line (-f) is not usable here: unattended-upgrade-shutdown --wait-for-signal
# and firefox's -signalPipe both make a bare "signal" look permanently running.
is_running() { pgrep -x "$1" > /dev/null 2>&1; }

wait_for_process() {
    local app="$1"
    local proc="${PROCESS[$app]}"
    local elapsed=0
    log "  Waiting for $app (pgrep: $proc)..."
    while ! is_running "$proc"; do
        sleep 1
        ((elapsed++))
        if [[ $elapsed -ge $SPAWN_WAIT_TIMEOUT ]]; then
            log "  TIMEOUT: $app did not start after ${SPAWN_WAIT_TIMEOUT}s"
            return 1
        fi
    done
    log "  $app ready (${elapsed}s)"
    return 0
}

# ================================================================
# PHASE 1: Spawn all missing processes
# ================================================================
log "=== Phase 1: Spawning missing processes ==="
spawned=()
for app in "${!COMMANDS[@]}"; do
    proc="${PROCESS[$app]}"
    if is_running "$proc"; then
        log "  $app: already running, skipping"
    else
        log "  $app: spawning ${COMMANDS[$app]}"
        niri msg action spawn -- "${COMMANDS[$app]}"
        spawned+=("$app")
    fi
done
log "Spawned ${#spawned[@]} process(es): ${spawned[*]:-none}"

sleep "$AFTER_SPAWN_SLEEP"

# ================================================================
# PHASE 2: Wait for all spawned processes to be running
# ================================================================
log "=== Phase 2: Waiting for processes to appear ==="
failed=()
for app in "${spawned[@]}"; do
    wait_for_process "$app" || failed+=("$app")
done

if [[ ${#failed[@]} -gt 0 ]]; then
    log "WARNING: ${#failed[@]} process(es) failed to start: ${failed[*]}"
else
    log "All ${#spawned[@]} spawned process(es) are running"
fi

sleep "$AFTER_WAIT_SLEEP"

if (( DELAY > 0 )); then
    log "=== Delay: waiting ${DELAY}s before assigning workspaces ==="
    sleep "$DELAY"
fi

# ================================================================
# PHASE 3: Move all windows to their target workspaces
# ================================================================
log "=== Phase 3: Assigning workspaces ==="
moved=()
moved_windows=0

# Snapshot niri's state once. Querying inside the loop costs a round-trip per
# app and races with windows that open while the loop runs.
windows_json=$(niri msg -j windows 2>/dev/null)
workspaces_json=$(niri msg -j workspaces 2>/dev/null)

for app in "${!WORKSPACE[@]}"; do
    proc="${PROCESS[$app]}"
    target="${WORKSPACE[$app]}"

    if ! is_running "$proc"; then
        log "  $app: not running, skipping"
        continue
    fi

    # Match niri windows by app_id containing APP_ID (case-insensitive).
    # Every match, not just the first: one app can own several windows (two
    # VS Code projects, three kitty terminals) and they all belong on the
    # same workspace.
    app_id_lower="${APP_ID[$app],,}"
    mapfile -t app_windows < <(jq -r --arg p "$app_id_lower" \
        '.[] | select((.app_id // "") | ascii_downcase | contains($p)) | "\(.id) \(.workspace_id)"' \
        <<< "$windows_json")

    if (( ${#app_windows[@]} == 0 )); then
        log "  $app: no niri window matched app_id ~= ${APP_ID[$app]}, skipping"
        continue
    fi

    log "  $app: ${#app_windows[@]} window(s) matched app_id ~= ${APP_ID[$app]}"
    app_moved=0
    for win in "${app_windows[@]}"; do
        read -r window_id workspace_id <<< "$win"

        # Resolve workspace_id → index and skip if already correct
        current_idx=$(jq -r --argjson wid "$workspace_id" \
            '.[] | select(.id == $wid) | .idx' <<< "$workspaces_json")

        if [[ "$current_idx" == "$target" ]]; then
            log "    window #$window_id: already on workspace $target, skipping"
            continue
        fi

        log "    window #$window_id: workspace $current_idx → $target"
        # --window-id addresses the window directly (niri >= 0.1.10), so no
        # focus-window hop is needed; --focus false keeps the focus where it is.
        niri msg action move-window-to-workspace \
            --window-id "$window_id" --focus false "$target"
        ((app_moved++))
        ((moved_windows++))
        sleep "$INTER_MOVE_SLEEP"
    done

    (( app_moved > 0 )) && moved+=("$app:$app_moved:$target")
done

log "=== Done: returning focus to workspace 1 ==="
niri msg action focus-workspace 1

# ================================================================
# PHASE 4: Report
# ================================================================
ELAPSED=$(( SECONDS - STARTED_AT ))

# The summary states the outcome; the icon carries it too, so a red rocket says
# "an app is missing" before a word is read.
if (( ${#failed[@]} > 0 )); then
    URGENCY="critical"
    GLYPH="$N_GLYPH_WARN"
    ACCENT="$N_RED"
    ICON="startup-failed"
    HEADLINE="${#failed[@]} app(s) did not start"
    TIMEOUT=0            # sticky: a missing app needs a look
else
    URGENCY="low"
    GLYPH="$N_GLYPH_ROCKET"
    ACCENT="$N_CYAN"
    ICON="startup-session"
    HEADLINE="session ready"
    TIMEOUT=8000
fi

# Row 1 — the counts, worst last so the red lands at the end of the line.
COUNTS="$(n_span "$moved_windows" "$N_BLUE") moved"
(( ${#failed[@]} > 0 )) && COUNTS+=" $(n_span "·" "$N_DIM") $(n_span "${#failed[@]} failed" "$N_RED")"
COUNTS+=" $(n_span "· ${ELAPSED}s" "$N_DIM")"
ROWS=("$(n_head_row "$GLYPH" "$ACCENT" "${#spawned[@]} spawned" "$COUNTS")")

# One row per app that failed to appear, then the workspace layout that was applied.
for app in "${failed[@]}"; do
    ROWS+=("$(printf '<tt>%s %s %s</tt>' \
        "$(n_span "$N_GLYPH_CROSS" "$N_RED")" \
        "$(n_span "$(n_escape "$app")" "$N_RED")" \
        "$(n_span "timed out after ${SPAWN_WAIT_TIMEOUT}s" "$N_DIM")")")
done

if (( ${#moved[@]} > 0 )); then
    for entry in "${moved[@]}"; do
        IFS=: read -r m_app m_count m_target <<< "$entry"
        # A window count only earns its space when there was more than one.
        label="$m_app"
        (( m_count > 1 )) && label+=" ×$m_count"
        # Two spaces of indent: the head row starts with a double-width glyph.
        ROWS+=("$(printf '<tt>  %s %s %s</tt>' \
            "$(n_escape "$label")" \
            "$(n_span "→" "$N_DIM")" \
            "$(n_span "workspace $m_target" "$N_CYAN")")")
    done
elif (( ${#failed[@]} == 0 )); then
    ROWS+=("$(n_dim_row "  every app already in place")")
fi

n_notify "Startup" "$ICON" "$URGENCY" "$TIMEOUT" "startup" \
    "$HEADLINE" "$(n_body "${ROWS[@]}")"
