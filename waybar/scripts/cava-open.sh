#!/usr/bin/env bash
# On-click for custom/cava: full cava in kitty with the bar's settings (cava.conf),
# minus its raw [output] section so cava draws in the terminal instead.
conf="${XDG_RUNTIME_DIR:-/tmp}/waybar-cava-term.conf"
awk '/^\[/{skip=($0=="[output]")} !skip' "$HOME/.config/waybar/scripts/cava.conf" > "$conf"
printf '\n[output]\nchannels = mono\n' >> "$conf"
exec kitty -e cava -p "$conf"
