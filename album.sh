#!/bin/bash

get_photos()
{
  local username="$1"
  local pages="$2"
  curl -s "http://www.album.bg/$username/?view=4&page="{1..$pages} | grep -Po 'Размер на оригинала:.*$' | cut -d \' -f 4
}

