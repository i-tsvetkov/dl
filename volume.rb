volinfo = `amixer -D pulse get Master`
muted   = volinfo[/\[(on|off)\]/, 1] != 'on'
volume  = volinfo[/\[(\d+)%\]/, 1].to_i

print "vol:\s#{volume}\s%#{muted ? "\s(muted)" : ''}"

