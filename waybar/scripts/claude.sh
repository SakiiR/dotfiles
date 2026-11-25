#!/usr/bin/env bash
# Waybar custom/claude: ✻ S<session%> W<week%> F<Fable week%> · <open sessions>
# Usage comes from the same endpoint as Claude Code's /usage (cached 2 min).
# Open sessions = live PIDs in ~/.claude/sessions/<pid>.json.
# The token is only read, never refreshed (refresh tokens rotate; a refresh here
# could log out running Claude Code sessions). If it has expired, the last
# cached values are shown, dimmed.
set -u
creds=~/.claude/.credentials.json
cache=${XDG_CACHE_HOME:-$HOME/.cache}/waybar-claude-usage.json
ttl=120

# --- open sessions -------------------------------------------------------
sessions=0 idle=0 busy=0
for f in ~/.claude/sessions/*.json; do
    [ -e "$f" ] || continue
    pid=$(basename "$f" .json)
    kill -0 "$pid" 2>/dev/null || continue
    [ "$(ps -o comm= -p "$pid")" = claude ] || continue
    sessions=$((sessions + 1))
    [ "$(jq -r '.status // ""' "$f" 2>/dev/null)" = idle ] && idle=$((idle + 1)) || busy=$((busy + 1))
done

# --- usage (cached) -------------------------------------------------------
stale=false
age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
if [ "$age" -ge "$ttl" ]; then
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds" 2>/dev/null)
    exp=$(jq -r '.claudeAiOauth.expiresAt // 0' "$creds" 2>/dev/null)
    if [ -n "$token" ] && [ "$exp" -gt "$(date +%s%3N)" ]; then
        resp=$(curl -sf --max-time 8 https://api.anthropic.com/api/oauth/usage \
            -H "Authorization: Bearer $token" -H "anthropic-beta: oauth-2025-04-20")
        if [ -n "$resp" ] && jq -e '.limits' <<< "$resp" >/dev/null 2>&1; then
            printf '%s' "$resp" > "$cache.tmp" && mv "$cache.tmp" "$cache"
        else stale=true; fi
    else stale=true; fi
fi

if [ ! -s "$cache" ]; then
    jq -cn --arg n "$sessions" '{text: ("✻ – · " + $n), tooltip: "Claude usage unavailable (token expired? start claude once)", class: "stale"}'
    exit 0
fi

jq -c --arg n "$sessions" --arg idle "$idle" --arg busy "$busy" --argjson stale "$stale" '
  def lim(k):  [.limits[] | select(.kind == k)][0];
  def fable:   [.limits[] | select(.kind == "weekly_scoped" and (.scope.model.display_name // "") == "Fable")][0];
  def pct(x):  if x == null then "–" else (x.percent | tostring) + "%" end;
  def when(x): if x == null or x.resets_at == null then "" else
                 " (resets " + (x.resets_at | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z")
                 | fromdateiso8601 + 30 | strflocaltime("%a %H:%M")) + ")" end;
  lim("session") as $s | lim("weekly_all") as $w | fable as $f
  | ([$s, $w, $f] | map(.percent // 0) | max) as $max
  | {
      text: ("✻ S" + pct($s) + " W" + pct($w) + " F" + pct($f) + " · " + $n),
      tooltip: ("Claude usage" + (if $stale then " (cached, token expired)" else "" end) + "\n"
        + "Session  " + pct($s) + when($s) + "\n"
        + "Week     " + pct($w) + when($w) + "\n"
        + "Fable    " + pct($f) + when($f) + "\n"
        + "Sessions " + $n + " open (" + $busy + " busy, " + $idle + " idle)"),
      class: (if $stale then "stale" elif $max >= 90 then "critical" elif $max >= 70 then "warning" else "normal" end),
      percentage: $max
    }' "$cache"
