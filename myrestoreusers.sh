#!/bin/sh
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/myrestoreusers.sh -O - | sh
if [ -f MySQLUserGrants.sql ]; then
	mysql < MySQLUserGrants.sql
	mysql -e 'FLUSH PRIVILEGES;'
else
exit 0
fi
