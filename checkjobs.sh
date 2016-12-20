#!/bin/bash
#to enable debug mode uncomment the string below
#do not enable on REAL PRODUCTION USE!
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/checkjobs.sh -O - | bash
if [ "$EUID" -ne 0 ]; then 
	echo -en "Have you forgotten that such things are being done only under the root?"
	
	exit 1
else

#BLACKLIST section:
#You can edit blacklist of words and path delimited by pipe below:
blacklist="(/usr/local/cpanel/|/var/cpanel|daily|monthly|hourly|weekly|run-parts|anacron)"

#PATH to cron files section:
#If Debian or ubuntu, most likely user job files located in subfolder	
	if [[ -d '/var/spool/cron/crontabs/' ]]; 
		then path="/var/spool/cron/crontabs/"	
		else #this is redhat default location
		path="/var/spool/cron/"
	fi
	
#EXPRESSIONS section:
	expEXC='^(#|;|[a-z]|[A-Z]|$|*#)' #exclude lines starting from symbols in pattern
	exp0='NF' #empty lines for awk
	expN='^..........' #minimal line length in symbols
	
#Now time to cat all -1 level finded in our cron directory files 
#and remove spaces&tabs from line start | find lines starting from *, @ and 0-9,
#filter the output, then count lines.
activelines=$(find $path -maxdepth 1 -type f -exec cat {} \; | sed 's/^[ \t]*//' | egrep ^'(\*|[0-9]|@)' | awk $exp0 | grep $expN | egrep -shi -v $blacklist | egrep -v $expEXC | wc -l)

#CHECK /etc section:
unlist="(0hourly|sysstat|raid-*|anacron|apt*|dpkg*|yum*|*rpm*|upstart|logr*|passwd|man-*|*locate|ntp|bsd*|*trim)"
sysfilter () { #shorten grep to function
egrep -shi -v $unlist
}
#expression for find:
exp4fnd="! -type d ! -name .placeholder ! -name 0anacron"
#run encounter if directory exists, use 0 variable if not
if [ -d '/etc/cron.daily/' ]; then
dailyt=$(find /etc/cron.daily/ $exp4fnd | sysfilter) 
daily=$(find /etc/cron.daily/ $exp4fnd | sysfilter|wc -l) 
else daily=0 
fi
if [ -d '/etc/cron.hourly/' ]; then
hourlyt=$(find /etc/cron.hourly/ $exp4fnd | sysfilter) 
hourly=$(find /etc/cron.hourly/ $exp4fnd | sysfilter|wc -l)
else hourly=0
fi
if [ -d '/etc/cron.weekly/' ]; then
weeklyt=$(find /etc/cron.weekly/ $exp4fnd | sysfilter)
weekly=$(find /etc/cron.weekly/ $exp4fnd | sysfilter|wc -l)
else weekly=0
fi
if [ -d '/etc/cron.monthly/' ]; then
monthlyt=$(find /etc/cron.monthly/ $exp4fnd | sysfilter) 
monthly=$(find /etc/cron.monthly/ $exp4fnd | sysfilter|wc -l)
else monthly=0
fi
if [ -d '/etc/cron.d/' ]; then
dt=$(find /etc/cron.d/ $exp4fnd | sysfilter) 
d=$(find /etc/cron.d/ $exp4fnd | sysfilter|wc -l)
else d=0
fi
#0hourly check lines
if [ -f '/etc/cron.d/0hourly' ]; then
hrl=$(cat /etc/cron.d/0hourly | sed 's/^[ \t]*//' | egrep ^'(\*|[0-9]|@)' | awk $exp0 | grep $expN | egrep -shi -v $blacklist | egrep -v $expEXC | wc -l)
else hrl=0
fi
echo -e "\n" cron.d: "\n""$dt"
echo -e "\n" monthly: "\n""$monthlyt"
echo -e "\n" hourly:"\n""$hourlyt"
echo -e "\n" weekly:"\n""$weeklyt"
echo -e "\n" daily:"\n""$dailyt"

#SUM all parts
activescripts=$((daily + hourly + monthly + weekly + d + hrl))
#DISPLAY count of files in /etc/cron.* subfolders:
echo -e "\n" from etc : "$activescripts" tasks! "\n"


#DISPLAY count of /var/spool/cron/* section:
	server=$(hostname)
		if [ "$activelines" -eq "0" ]; then 
		echo -en Nothing found at server called $server, Carl ! '\n'
		elif [ "$activelines" -gt "0" ]; then 
		echo -en $server is configured to run $activelines active cron jobs '\n'
		elif [[ ! "$activelines" ]]; then echo -en FUCKING ERROR!!! '\n'
		fi
fi
#FIN!
