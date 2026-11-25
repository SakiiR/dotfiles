#!/usr/bin/env bash
# Waybar custom/docker: running container count; tooltip = `docker stats` snapshot.
stats=$(docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' 2>/dev/null) || {
    jq -cn '{text: "󰡨 –", tooltip: "Docker unavailable", class: "down"}'; exit 0; }
stats=$(sed "s| / [^\t]*$||" <<< "$stats")
count=$(grep -c . <<< "$stats")
table=$( { printf 'NAME\tCPU\tMEM\n'; sort -t$'\t' -k2 -rn <<< "$stats"; } \
    | column -t -s$'\t' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
jq -cn --arg n "$count" --arg t "$table" \
    '{text: ("󰡨 " + $n), tooltip: ("<tt>" + $t + "</tt>"), class: (if $n == "0" then "idle" else "running" end)}'
