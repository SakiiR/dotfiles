#!/bin/bash

WINDOW_NAME=$1

while true 
do
    echo "Waiting for window "$WINDOW_NAME   
    if wmctrl -l | grep -i $1 ; then
      echo "FOUND !"
      exit 1
    fi
    sleep 0.2 
done
