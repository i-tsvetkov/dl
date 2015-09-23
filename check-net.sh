#!/bin/bash

while :
do
  ping -c1 8.8.8.8
  if [ $? -eq 0 ]; then
    notify-send 'Internet is Up!' -i internet
    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    break
  fi
  sleep 1
done

