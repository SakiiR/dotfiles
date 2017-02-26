#!/bin/bash

amixer -q sset Master 3%+
aplay ~/.config/scripts/vol.wav
notify-send -t 100 $(sh ~/.config/scripts/getvolume)

