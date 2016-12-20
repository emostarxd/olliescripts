#!/bin/sh
#to enable debug mode uncomment the string below
#do not enable on REAL PRODUCTION USE!
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/mydump.sh -O - | sh

###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response

prepare() {
list=$(ls -l | grep sql.gz | awk '{print $9}')
echo "$list"
}

action() {
prepare
for db in "$list"
do
	# sanitize BASE.sql.gz to BASE
	dbname=$(echo $db | sed 's/\.sql.gz//')
	# dump each database in a separate file
	zcat $db | mysql $dbname
  
done
}
action

#if [[ -f MySQLUserGrants.sql ]]; then
#	mysqldump -A < MySQLUserGrants.sql
#	mysql -e 'FLUSH PRIVILEGES;'
#else
#exit 0
#fi
