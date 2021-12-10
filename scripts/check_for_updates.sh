#!/bin/sh

count=$(yaourt -Qu | wc -l | tr -d '\n')

echo $count

if [ "$count" -ne "0" ] ; then
  notify-send  'Yaourt' 'Updates available: '$count
fi
