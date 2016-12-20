#!/bin/sh
#to enable debug mode uncomment the string below
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# get this script latest version: wget -q http://triforceweb.com/timeOSD.sh
###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response
get_display () {
who \
| grep ${1:-$LOGNAME} \
| perl -ne 'if ( m!\(\:(\d+)\)$! ) {print ":$1.0\n"; $ok = 1; last} END {exit !$ok}'
}
DISPLAY=$(get_display) || exit
export DISPLAY
kiev=$(TZ=":Europe/Kiev" date +%T)
usa=$(TZ=":US/Eastern" date +%T)
spacer=$(echo "")
notify-send -i "clock" "Время в Киеве: $kiev" "$spacerВремя в США: $usa" -h int:x:500 -h int:y:500
