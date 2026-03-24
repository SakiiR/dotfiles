#!/bin/bash

notify-send 'Locking ...' --expire-time=5000

#SOURCE="/home/edupard/Pictures/forest.png"
SOURCE="/home/edupard/Pictures/space.jpg"
TARGET="/tmp/lockscreen.png"
LOCATION="Paris"
OPTIONS="tqp0"
FILE_EXPIRATION="08:00:00" # 8h00 min
BLUR="0x8"

# Cache system, do not curl wttr.in everytime we need to lock
now=$(date +%s)
file_mtime=$(stat -c %Y "${TARGET}")
expiration=`date -d "1970-01-01 $FILE_EXPIRATION Z" +%s`

if [ ! -f "${TARGET}" ] | (( now - file_mtime > expiration ))
then
    echo "File doesn't exists or too old"
    convert "${SOURCE}" -blur "${BLUR}" <( curl -m10 -s "wttr.in/${LOCATION}_${OPTIONS}.png" ) -geometry +50+50 -composite "${TARGET}"
fi

i3lock                                  \
  --show-failed-attempts                \
  --nofork                              \
  --image "${TARGET}"                   \
  --clock                               \
  --bar-indicator                       \
  --bar-direction=1                     \
  --bar-orientation=horizontal          \
  --bar-step=60                         \
  --bar-periodic-step=2                 \
  --bar-count=200                       \
  --bar-max-height=500                  \
  --bar-base-width=8                    \
  --bar-total-width="w"                 \
  --bar-pos="0: h+20"                   \
  --color=1E2030FF                      \
  --inside-color=24273AFF               \
  --ring-color=8AADF4FF                 \
  --line-color=8AADF4FF                 \
  --insidever-color=A6DA95FF            \
  --ringver-color=A6DA95FF              \
  --insidewrong-color=ED8796FF          \
  --ringwrong-color=ED8796FF            \
  --separator-color=B7BDF8FF            \
  --keyhl-color=F5A97FFF                \
  --bshl-color=ED8796FF                 \
  --verif-color=B7BDF8FF                \
  --wrong-color=ED8796FF                \
  --modif-color=F5BDE6FF                \
  --time-color=B7BDF8FF                 \
  --date-color=B7BDF8FF                 \
  --layout-color=B7BDF8FF               \
  --greeter-color=8AADF4FF              \
  --time-str="%H:%M"                    \
  --date-str="%A, %Y-%m-%d"             \
  --radius=80                           \
  --ring-width=5  #--no-verify

