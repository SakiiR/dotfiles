#!/bin/bash

amixer -q sset Master 3%-
notify-send -t 100 $(sh /home/sakiir/.scripts/getvolume)

