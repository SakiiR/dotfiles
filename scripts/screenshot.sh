#!/bin/bash

PIX="https://pix.watch"
API=$PIX/api

scrot -z -d 1 -e 'mv $f /tmp/ && cp /tmp/$f /tmp/last.png'
# Send the screenshot over pix.watch
CONTENT=$(curl -X POST --silent -F pic=@/tmp/last.png $API)
URL=$PIX$CONTENT
rm /tmp/last.png
xdg-open "$URL"
echo -ne $URL | xclip -selection clipboard
notify-send --urgency low "Screenshot done ! $URL Copied to clipboard"

