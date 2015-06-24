#!/bin/bash

while :
do
  ping -c1 8.8.8.8
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done

