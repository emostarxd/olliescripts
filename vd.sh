#!/bin/bash
#to enable debug mode uncomment the string below
#do not enable on REAL PRODUCTION USE!
#set -x
shopt -s expand_aliases #export aliases to real terminal
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/vd.sh -O - | bash
	INVERSE='\033[7m'  #  ${INVERSE}
	NORMAL='\033[0m'   #  ${NORMAL}
	LCYAN='\033[1;36m'     #  ${LCYAN}
	BGCYAN='\033[46m'     #  ${BGCYAN}
	LRED='\033[1;31m'       #  ${LRED}
###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response

alias arestart='service httpd restart || /etc/init.d/httpd restart'
alias areload='service httpd reload || /etc/init.d/httpd reload'
alias astop='service httpd stop || /etc/init.d/httpd stop'
alias astart='service httpd start || /etc/init.d/httpd start'
alias killphp='killall php && wait 2 && echo $(ps aux|grep php)||killall php-cgi && wait 2 && echo $(ps aux|grep php)'
alias mrestart='service mysql restart||service mariadb restart||/etc/init.d/mysqld restart||/etc/init.d/mysql restart'
alias getvhosts="grep ServerName | awk '{print $2}'"
alias getphpini="cat /etc/php.ini | grep -v ^[\;] | awk 'NF' > /etc/php.ini.dump"

######   PART 1   ######
detectonport () { #use netstat to detect web server daemon on port 80
	software80=$(netstat -tulpn | grep :80 | awk -F "/" '{print $NF}' | sed s/' '//g) #last word from output
}
unknownserver () { #if detected something other, not apache, lighthttpd or nginx, or not detected
	if [[ ! -z $software80 ]]; then 
		echo -en ${LRED}Unfortunately Apache is not present on this server. '\n' Your web daemon is called ${INVERSE}$software80${NORMAL} ${LRED}running on port 80 detected by netstat'\n' Please try to review your virtual hosts without this script!${NORMAL} '\n'
		exit 0
	else
		echo -en ${LRED}Unfortunately Apache is not present on this server. Your web daemon is not found on port 80 using netstat. '\n' Please use ${INVERSE}"lsof -i :80 | grep LISTEN"${NORMAL} ${LRED}or try to start webserver daemon! '\n'Also you can review your virtual hosts without this script!${NORMAL} '\n'
		exit 0
	fi
}
notapache () { #if detected something other, not apache
	if [[ $software80 == ngi* ]]; then #if nginx
		nginxgetpath=$(nginx -V 2>&1 | grep -o '\-\-conf-path=\(.*conf\)' | cut -d '=' -f2)
		if [[ ! -z $nginxgetpath ]]; then
			echo -en Current active config file: ${BGCYAN}$nginxgetpath${NORMAL} for NGINX which is running on port 80 '\n'
		fi
		if [[ -z $nginxgetpath ]]; then #if nginx but can't get path, method 2
			nginxconf=$(ps aux | grep nginx | grep "[c]onf" | awk '{print $(NF)}')
			echo -en Current active config file: ${BGCYAN}$nginxconf${NORMAL} for NGINX which is running on port 80 '\n'
		else
			echo -e Your web-server is ${BGCYAN}$software80${NORMAL} detected as NGINX but config file is not located, mumble-mumble! '\n'
		fi
	elif [[ $software80 == lig* ]]; then #if lighthttpd
		lightconf=$(ps aux | grep lightht | grep "[c]onf" | awk '{print $(NF)}')
		echo -en Current active config file: ${BGCYAN}$lightconf${NORMAL} for LightHTTPD which is running on port 80 '\n'
	else
		unknownserver
	fi
}
psanitizer () { #search webserver process, get path and sanitize it
		getconf1=$($(ps ax | grep -m 1 $software80 | awk '{print $5}') -V | grep HTTPD_ROOT | sed 's/.*"\(.*\)"[^"]*$/\1/')
		getconf2=$($(ps ax | grep -m 1 $software80 | awk '{print $5}') -V | grep SERVER_CONFIG_FILE | sed 's/.*"\(.*\)"[^"]*$/\1/')
		#old		getconf1=$($(ps ax -o comm | grep -m 1 $software80) -V | grep HTTPD_ROOT | sed 's/.*"\(.*\)"[^"]*$/\1/')
		#old		getconf2=$($(ps ax -o comm | grep -m 1 $software80) -V | grep SERVER_CONFIG_FILE | sed 's/.*"\(.*\)"[^"]*$/\1/')
}
locatecases () {
	if [[ $software80 == http* ]]; then #for httpd process (RHEL,Fedora,CentOS,etc rpm-based)
		psanitizer
	fi
	if [[ $software80 == apa* ]]; then #for apache2 debian-like daemons
#		psanitizer
		getconf1=$(apache2ctl -V | grep HTTPD_ROOT | sed 's/.*"\(.*\)"[^"]*$/\1/')
        getconf2=$(apache2ctl -V | grep SERVER_CONFIG_FILE | sed 's/.*"\(.*\)"[^"]*$/\1/') 
	fi
	if [ $software80 != "apache2" ] && [ $software80 != "httpd" ]; then #if not apache or httpd
		notapache
	fi
}

failnetstat () { #if netstat is useless or not installed
	planb=$(lsof -i :80 | grep LISTEN | awk 'NR == 1{print$1}')
	software80=$planb #use reserve value as main
	locatecases #return to main thread
}

whereismywebserver () {
	detectonport #detect process on port 80
	if [[ -z $software80 ]]; then #if not detected
		failnetstat
	fi
	locatecases
	confpath=$getconf1/$getconf2
}

whereismywebserverresponse () {
	echo -en '\n' ${BGCYAN}'        << ----- =====   VHOST DETECTOR   ===== ---- >>     '${NORMAL}'\n'
	echo -en Your webserver looks like ${INVERSE}$software80${NORMAL} '\n'
	echo -en Current active config file: ${INVERSE}$confpath${NORMAL} '\n'
}

###### RUN PART 1 ######
whereismywebserver

######   PART 2   ######
#Set config path to find conf files
if [ '$getconf1' != "/" ]; then
	cfpath=$getconf1 #AUTO
	whereismywebserverresponse
else 
	whereismywebserver #Show info for manual work
fi

#cat all configuration files, filter junk: commented lines, empty lines, etc
rawdata=$(find $cfpath -type f -name '*.conf' -exec cat {} \;| sed 's/^[ \t]*//' | grep -v ^[#] | awk 'NF')
echo -en ${LCYAN}${BGCYAN}'========================================    <<< YOUR VIRTUAL HOSTS >>>    =========================================='${NORMAL} '\n'
#show column headings
echo -en ${INVERSE}'VHOST:PORT' '(DOMAIN' 'ALIASES' 'DIRECTORY)' '\n' | column -t
echo -en ${NORMAL}

#parse prefiltered data
echo "$rawdata"| awk \
                '/^<VirtualHost*/,/^<\/VirtualHost>/\
                        {if\
                        (/^<\/VirtualHost>/)p=1;\
                        if\
                                        (/ServerName|VirtualHost|ServerAlias|DocumentRoot|## User/)out = \
                                                out (out?OFS:"") (/User/?$3:$2)}\
                                p{print out;p=0;out=""}' | 
sed -s 's/>//g' | column -t
echo -en ${LCYAN}${BGCYAN}'===================================================================================================================='${NORMAL} '\n'
#FIN!
