#!/bin/bash

killall -q xautolock

pactl set-sink-mute 0 0
pactl set-sink-volume 0 200%

TV=nova

[[ $# -eq 1 ]] && TV="$1"

nova()
{
  rtmpdump\
    --rtmp     'rtmp://edge2.cdn.bg:2010/fls'\
    --app      'fls'\
    --flashVer 'LNX 11,8,800,96'\
    --swfVfy   'http://i.cdn.bg/eflash/jwNTV/player-at.swf'\
    --pageUrl  'http://i.cdn.bg/live/0OmMKJ4SgY'\
    --playpath 'ntv_2.stream'\
    --token    'N0v4TV6#2'\
    --live --flv - --quiet | mpv --fs --mute=no --volume=100 --cache=10000\
    --cache-min=10\
    --title='NovaTV - На живо'\
    --really-quiet - &> /dev/null
}

btv()
{
  rtmpdump\
    --rtmp     'rtmp://46.10.150.113:80/ios'\
    --app      'ios'\
    --flashVer 'LNX 11,8,800,96'\
    --swfVfy   'http://images.btv.bg/fplayer/flowplayer.commercial-3.2.5.swf'\
    --pageUrl  'http://www.btv.bg/live/'\
    --playpath 'btvbglive'\
    --live --flv - --quiet | mpv --fs --mute=no --volume=100 --cache=10000\
    --cache-min=10\
    --title='BTV - На живо'\
    --really-quiet - &> /dev/null
}

bnt()
{
  local pageUrl='http://cdn.bg/live/4eViE8vGzI'
  rtmpdump\
    --rtmp     'rtmp://edge11.cdn.bg:2020/fls'\
    --app      'fls'\
    --flashVer 'LNX 11,8,800,96'\
    --swfVfy   'http://cdn.bg/eflash/jwplayer510/player.swf'\
    --pageUrl  "$pageUrl"\
    --playpath "bnt.stream?at=$(curl -s -H 'Referer: http://tv.bnt.bg/bnt1/16x9/' "$pageUrl" | grep -oP 'bnt.stream\?at=\K\w+')"\
    --token    'B@1R1st1077'\
    --live --flv - --quiet | mpv --fs --mute=no --volume=100 --cache=10000\
    --cache-min=10\
    --title='BNT - На живо'\
    --really-quiet --force-window - &> /dev/null
}

go_tv()
{
  case "$TV" in
    nova) nova ;;
    btv)  btv ;;
    bnt)  bnt ;;
    *)    exit `false` ;;
  esac
}

wait_tv()
{
  for i in {1..60}
  do
    expr $i \* 10 / 6
    sleep 1
  done | zenity --progress --auto-close &> /dev/null
}

log()
{
  echo -e "`date`:\t$1" >> /tmp/tv.log
}

main()
{
  lockfile-check .tv
  [[ $? -ne 0 ]] && lockfile-create .tv
  while :
  do
    go_tv
    log "($?) The video stream stopped!"
    ping -c4 8.8.8.8 &> /dev/null && log 'Net up.' || log 'Net down!'
    wait_tv
    if [ $? -ne 0 ]; then
      lockfile-remove .tv
      exit
    fi
  done
}

main

