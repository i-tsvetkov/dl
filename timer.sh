#!/bin/bash

function timer {
  function time_title {
    echo -n "$@" | sed -r 's/([0-9]+)(s| |$)/\1 sec/g;s/m/ min/g'
  }
  sleep "$@"\
  && paplay '/usr/share/sounds/freedesktop/stereo/bell.oga'\
  && notify-send "$(time_title "$@")"\
                 'it is time!' -i clock
}

timer "$@"

