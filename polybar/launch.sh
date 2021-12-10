#!/bin/bash

pkill polybar
MONITOR=$(polybar -m | tail -n 1 | awk -F ':' '{print $1}') polybar main
