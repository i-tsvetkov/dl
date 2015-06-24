#!/bin/bash

while :
do
  ping -c1 8.8.8.8
  if [ $? -eq 0 ]; then
    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    break
  fi
  sleep 1
done

