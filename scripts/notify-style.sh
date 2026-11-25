#!/usr/bin/env bash
# notify-style.sh — the shared desktop-notification style of the local scripts.
#
# Source it, do not run it:
#     source "$HOME/.local/lib/notify-style.sh"
#
# dunst runs with `markup = full` and Hack Nerd Font (see ~/.config/dunst/dunstrc),
# so a body is Pango markup and can carry Nerd Font glyphs. The style comes from
# ~/.local/bin/claude-credit-check:
#
#   * one <tt> row per fact, so the columns line up between rows
#   * a coloured Nerd Font glyph at the start of the head row, as the accent
#   * green while comfortable, amber when it needs watching, red when urgent
#   * dim grey for anything secondary (paths, timestamps, reset times)
#   * a transparent-background icon from ~/.local/share/icons/hicolor/128x128/apps,
#     because every dunst urgency paints a near-black card
#   * a stack tag, so a new reading replaces the previous one instead of piling up
#   * sticky (-t 0) only while something needs doing
#
# shellcheck shell=bash

# --------------------------------------------------------------------------- palette

N_DIM="#8a9a98"
N_RED="#f7768e"
N_AMBER="#e0af68"
N_GREEN="#9ece6a"
N_CYAN="#7dcfff"
N_PURPLE="#bb9af7"
N_BLUE="#7aa2f7"

N_ICON_DIR="$HOME/.local/share/icons/hicolor/128x128/apps"

# Nerd Font glyphs shared by several scripts
N_GLYPH_OK=$''      # nf-fa-check
N_GLYPH_WARN=$''    # nf-fa-warning
N_GLYPH_INFO=$''    # nf-fa-info_circle
N_GLYPH_BOLT=$''    # nf-fa-bolt
N_GLYPH_ROCKET=$''  # nf-fa-rocket
N_GLYPH_BOX=$''     # nf-fa-archive
N_GLYPH_CROSS=$''   # nf-fa-times

# --------------------------------------------------------------------------- environment

# Cron starts without a PATH to ~/.local/bin and without the dbus and display
# variables notify-send needs, so a notification would fail silently.
n_prepare_env() {
  export DISPLAY="${DISPLAY:-:0}"
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
  export PATH="$HOME/.local/bin:${PATH:-/usr/local/bin:/usr/bin:/bin}"
}

# --------------------------------------------------------------------------- markup

# Pango markup is enabled, so every piece of data has to be escaped.
n_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<< "${1-}"; }

n_span() { printf '<span foreground="%s">%s</span>' "$2" "$1"; }

# Green while comfortable, amber when it needs watching, red when nearly spent.
# Takes a remaining percentage.
n_colour_for() {
  if (( $1 <= 25 )); then
    printf '%s' "$N_RED"
  elif (( $1 <= 50 )); then
    printf '%s' "$N_AMBER"
  else
    printf '%s' "$N_GREEN"
  fi
}

# Urgency from a remaining percentage, on the same thresholds as the colours.
n_urgency_for() {
  if (( $1 <= 10 )); then
    printf 'critical'
  elif (( $1 <= 25 )); then
    printf 'normal'
  else
    printf 'low'
  fi
}

# n_bar <remaining-percent> [cells] — a meter of the remaining share, coloured by
# how much is left.
n_bar() {
  local left=$1 cells=${2:-10} colour filled empty out=""
  colour=$(n_colour_for "$left")
  filled=$(( (left * cells + 50) / 100 ))
  (( filled > cells )) && filled=$cells
  (( left > 0 && filled == 0 )) && filled=1   # never show an empty bar while something remains
  empty=$(( cells - filled ))

  # printf replays its format once even with no arguments, so guard both counts
  (( filled > 0 )) && out+="$(n_span "$(printf '█%.0s' $(seq "$filled"))" "$colour")"
  (( empty > 0 ))  && out+="$(n_span "$(printf '░%.0s' $(seq "$empty"))" "$N_DIM")"
  printf '%s' "$out"
}

# The row builders below print no trailing newline, because `$(...)` strips one
# anyway. Join them with n_body instead.
#
# n_body <row>... — one row per line, which is what dunst renders as the body.
n_body() { local IFS=$'\n'; printf '%s' "$*"; }

# n_meter_row <label> <remaining-percent> [note] — label, meter, percentage, dim note.
n_meter_row() {
  printf '<tt>%-7s </tt>%s<tt> %3d%% left</tt>' "$1" "$(n_bar "$2")" "$2"
  [[ -n "${3-}" ]] && printf '<tt>  %s</tt>' "$(n_span "· $(n_escape "$3")" "$N_DIM")"
}

# n_head_row <glyph> <accent> <bold-text> [rest-markup] — the accent row of a body.
n_head_row() {
  printf '<tt>%s <b>%s</b>' "$(n_span "$1" "$2")" "$(n_escape "$3")"
  [[ -n "${4-}" ]] && printf ' %s' "$4"
  printf '</tt>'
}

# n_dim_row <text> — a secondary row: a path, a log file, a timestamp.
n_dim_row() { n_span "<tt>$(n_escape "$1")</tt>" "$N_DIM"; }

# --------------------------------------------------------------------------- send

# n_notify <app> <icon> <urgency> <timeout-ms> <stack-tag> <summary> <body>
#
# `icon` is either a bare name from ~/.local/share/icons/hicolor/128x128/apps or a
# full path. The summary stays plain text: dunst does not read markup there, so an
# escaped summary would show `-&gt;`.
n_notify() {
  local app=$1 icon=$2 urgency=$3 timeout=$4 tag=$5 summary=$6 body=$7

  [[ "$icon" != /* ]] && icon="$N_ICON_DIR/$icon.png"
  [[ -f "$icon" ]] || icon=""

  local args=(-u "$urgency" -a "$app" -t "$timeout")
  [[ -n "$icon" ]] && args+=(-i "$icon")
  [[ -n "$tag" ]] && args+=(-h "string:x-dunst-stack-tag:$tag")

  command -v notify-send > /dev/null 2>&1 || return 0
  notify-send "${args[@]}" "$summary" "$body"
}
