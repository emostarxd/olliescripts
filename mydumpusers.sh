#!/bin/sh
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/mydumpusers.sh -O - | sh
mysql --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql --skip-column-names -A | grep -v 'root' | sed 's/$/;/g' > MySQLUserGrants.sql
