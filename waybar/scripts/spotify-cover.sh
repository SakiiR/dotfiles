#!/usr/bin/env bash
# Prints the path of the current Spotify album cover (cached), or nothing if Spotify is not running.
url=$(gdbus call --session --dest org.mpris.MediaPlayer2.spotify \
        --object-path /org/mpris/MediaPlayer2 \
        --method org.freedesktop.DBus.Properties.Get \
        org.mpris.MediaPlayer2.Player Metadata 2>/dev/null \
      | grep -oP "'mpris:artUrl': <'\K[^']+")
[[ -z $url ]] && exit 0
dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-spotify"
mkdir -p "$dir"
file="$dir/${url##*/}.jpg"
if [[ ! -s $file ]]; then
    curl -sfL --max-time 5 "$url" -o "$file.tmp" && mv "$file.tmp" "$file" || { rm -f "$file.tmp"; exit 0; }
    # keep the cache small
    ls -1t "$dir"/*.jpg 2>/dev/null | tail -n +21 | xargs -r rm -f
fi
echo "$file"
