#!/usr/bin/env bash
# Waybar custom/cava: tiny spectrum next to Spotify.
# When silent, emit an invisible same-width placeholder (baseline bars wrapped
# in a near-transparent Pango span) instead of an empty string, so the module
# keeps its exact footprint instead of collapsing — which made it blink.
conf="$HOME/.config/waybar/scripts/cava.conf"
pkill -f "cava -p $conf" 2>/dev/null
exec cava -p "$conf" 2>/dev/null \
    | LC_ALL=C.UTF-8 sed -u -n \
        -e 's/\x0//g' \
        -e '/^[0-7]*$/!d' \
        -e 'y/01234567/▁▂▃▄▅▆▇█/' \
        -e 's/^▁\+$/<span alpha="1%">&<\/span>/' \
        -e p
