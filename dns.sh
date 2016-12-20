#!/bin/sh
# Author: Oliver Rex, http://triforceweb.com/
#rename this file to dns and copy to /usr/bin
#usage: dns domain.com
echo DNS REAL LOOKUP by triforce. "$1" domain realtime state:
echo ""
dig +trace "$1" | grep "$1" | grep -v 'SECTION' | grep -v 'DiG'	
