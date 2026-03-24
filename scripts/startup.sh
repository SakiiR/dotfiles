#!/bin/bash

processes=(
    "spotify"
    "firefox-esr"
    "keepassxc"
    "discord"
    "kitty"
    "zoom"
    "code"
)

for process in ${processes[@]}; do
    echo "Process: $process"
    pgrep "$process" || "$process"&
done
