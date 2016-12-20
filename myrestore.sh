#!/bin/sh
#to enable debug mode uncomment the string below
#do not enable on REAL PRODUCTION USE!
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/mydump.sh -O - | sh

###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response

prepare() { #get list of database dumps
	list=$(ls -l | grep sql.gz | awk '{print $9}')
}
prepare

action() { #run import if confirmed by user

	for db in "$list"
	do
		# sanitize BASE.sql.gz to BASE
			dbname=$(echo $db | sed 's/\.sql.gz//')
		# create base in mysql if not exist
			mysql -e "CREATE DATABASE IF NOT EXISTS $dbname;"
		# restore each database in a separate file
			zcat $db | mysql $dbname
	done
}

echo "The following databases will be created if not exist, data will be overwritten:"
echo "$list"
read -p "Continue? (y/N): " CONFIRM_INPUT
while true
do
	case $CONFIRM_INPUT in
		[yY]* ) action;;
		[nN]* ) exit;;
		* ) echo "Dude, just enter Y or N, please."; break ;;
	esac
done

importusers() {
	mysql < MySQLUserGrants.sql
	mysql -e 'FLUSH PRIVILEGES;'
}

if [ -f MySQLUserGrants.sql ]; then
	read -p "File with users and grants is detected. Continue? (y/N): " CONFIRM_INPUT
	while true
	do
		case $CONFIRM_INPUT in
			[yY]* ) importusers;;
			[nN]* ) exit;;
			* ) echo "Dude, just enter Y or N, please."; break ;;
		esac
	done
else
	exit 0
fi
