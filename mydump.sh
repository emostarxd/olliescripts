#!/bin/sh
#to enable debug mode uncomment the string below
#do not enable on REAL PRODUCTION USE!
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# run this script latest version: wget -q http://triforceweb.com/mydump.sh -O - | sh

###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response

prepare() {
list=$(mysql --execute="show databases" | awk '{print $1}' | grep -iv ^Database$ | egrep -v '(information_schema|perfomance_schema|debian-sys-maint|phpmyadmin|mysql)')
echo "$list"
}

action() {
prepare
for db in "$list"
do
	#mysql $db -e "FLUSH TABLES WITH READ LOCK; DO SLEEP(3600);" & sleep 3

  # dump each database in a separate file
  mysqldump --single-transaction -R -E --triggers "$db" | gzip > "$db.sql.gz"
  
  	#kill $! 2>/dev/null
	#wait $! 2>/dev/null
done
}
action
#mysql --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql --skip-column-names -A | grep -v 'root' | sed 's/$/;/g' > MySQLUserGrants.sql
