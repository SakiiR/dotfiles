#!/bin/bash

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

dunstify 'Locking ...' --timeout=5000

SOURCE="$HOME/Pictures/forest.png"
TARGET="/tmp/lockscreen.png"
LOCATION="Paris"
OPTIONS="0qp"
FILE_EXPIRATION="08:00:00"
BLUR="0x8"

# Cache blurred lockscreen image, regenerate after 8h
now=$(date +%s)
file_mtime=$(stat -c %Y "${TARGET}" 2>/dev/null || echo 0)
expiration=$(date -d "1970-01-01 $FILE_EXPIRATION Z" +%s)

if [ ! -f "${TARGET}" ] || (( now - file_mtime > expiration )); then
    convert "${SOURCE}" -blur "${BLUR}" \
        <( curl -m10 -s "wttr.in/${LOCATION}_${OPTIONS}.png?t=90" ) \
        -gravity NorthWest -geometry +40+20 -composite "${TARGET}" 2>/dev/null \
    || convert "${SOURCE}" -blur "${BLUR}" "${TARGET}"
fi

swaylock                                \
  --show-failed-attempts                \
  --image "${TARGET}"                   \
  --color=0e1514ff                      \
  --inside-color=1a2120ff               \
  --ring-color=80d5d1ff                 \
  --line-color=3f4948ff                 \
  --inside-ver-color=252b2bff           \
  --ring-ver-color=9cf1eeff             \
  --inside-wrong-color=252b2bff         \
  --ring-wrong-color=ffb4abff           \
  --separator-color=3f4948ff            \
  --key-hl-color=9cf1eeff               \
  --bs-hl-color=ffb4abff                \
  --text-color=dde4e3ff                 \
  --text-ver-color=bec9c7ff             \
  --text-wrong-color=ffb4abff           \
  --indicator-radius=80                 \
  --indicator-thickness=5

