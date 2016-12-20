#!/bin/bash
#to enable debug mode uncomment the string below
#do not enable on REAL moving operations!
#set -x
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/olliescripts$$
trap "rm -f $tempfile" 0 1 2 5 15
INVERSE='\033[7m'  #  ${INVERSE}
BLUE='\033[1;34m'  #  ${BLUE}
RED='\033[1;31m'   #  ${RED} 
YELLOW='\033[0;33m'#  ${YELLOW}
BG='\033[47m'      #  ${BG}
NORMAL='\033[0m'   #  ${NORMAL}
if [ "$EUID" -ne 0 ]; then 
#if [ whoami != root ]; then
echo -en "${RED}Have you forgotten that such things are being done only under the root?${NORMAL}" echo -e "\n"  
exit 1
else
dialog --backtitle 'UaGmt: USERS and GROUPS: moving tool' \
--title 'UaGmt 0.8.1 beta' \
--msgbox "RUN AS [ROOT] OR WITH [SUDO] RIGHTS! Released by Oliver Rex in November, 2016. Sofware version 0.8.2" 8 40
fi

#Functions block
dircreate() { #check entered by admin path and create a folder if not present
		if [[ ! -d $path ]]; then
		echo -en "Trying to create..." echo -e "\n"
		mkdir -p $path
			if [[ -d $path ]]; then
			echo -e "\n"
			echo -en "${BLUE}Directory $path was created${NORMAL}" echo -e "\n"
			fi
		fi
}
#divider
overwriteetc() {
	CAT1=$(sudo cat $MIGDIR/passwd.mig >> /etc/passwd | wc -l)
echo -en "${BLUE}/etc/passwd : $CAT1 users processed${NORMAL}" "\n"
	CAT2=$(sudo cat $MIGDIR/group.mig >> /etc/group | wc -l)
echo -en "${BLUE}/etc/group : $CAT2 groups processed${NORMAL}" "\n"
	CAT3=$(sudo cat $MIGDIR/shadow.mig >> /etc/shadow | wc -l)
echo -en "${BLUE}/etc/shadow : $CAT3 users processed${NORMAL}" "\n"
	CAT4=$(sudo cat $MIGDIR/gshadow.mig >> /etc/gshadow | wc -l)
echo -en "${BLUE}/etc/gshadow : $CAT4 groups processed${NORMAL}" "\n"
echo -en "===================" "\n"
}
#divider
yesnopopup() {
dialog --title "Overwrite file" \
--backtitle "Modify the system files to add new lines" \
--yesno "Confirm only if you have maked a backups of /etc/passwd,shadow,group and gshadow" 7 60
response=$?
case $response in
   0) overwriteetc;;
   1) echo -en "Files are not updated, cancelled by user choice" echo -e "\n";;
   255) "[ESC] key pressed. exiting...";;
esac   
}
#divider
restoreusers() {

echo -en "${INVERSE}Type here the path to saved original system files before import, \n ${INVERSE}default path is ${RED} [ /root/backup_originals ] ${NORMAL}${INVERSE} : ${NORMAL}" 
read -er capture
if [[ ! -z $capture ]]; then
	export path=$capture
	echo -en "${YELLOW}Files will be copied to: ${RED} $path ${NORMAL}" echo -e "\n"
dircreate

elif [[ -z $capture ]]; then
	pathdef="/root/backup_originals"
	export path=$pathdef
	echo -en "${BG}${YELLOW}Files will be copied to: ${BLUE} $path ${NORMAL}" echo -e "\n"
dircreate
fi

if	[[ -d $path ]]; then
			echo -en "${BLUE}Path to original OS user and group files: $path ${NORMAL}"
		else echo -en "${RED}ERR:Can't create the directory!${NORMAL}"
			ls -la $path | grep passwd
			exit 1
fi

if	cp -v /etc/passwd /etc/shadow /etc/group /etc/gshadow $path; then
			echo -en "${BLUE}Backup created (4 files)${NORMAL}"
		else echo -en "${RED}ERR:Original files from /etc copying process was failed!${NORMAL}"
fi

echo -en "===================" "\n"
echo -en "${INVERSE}Type here the path to the source server files, \n ${INVERSE}default path is ${BLUE} [ /root/move ] ${NORMAL}${INVERSE} : ${NORMAL}" 
read -er capture
if [[ ! -z $capture ]]; then
	export MIGDIR=$capture
	echo -en "${YELLOW}Files will be copied to: ${BLUE} $MIGDIR ${NORMAL}" echo -e "\n"
	yesnopopup
	echo -en "${BG}${BLUE}ALL FILES ARE DONE!${NORMAL}"
elif [[ -z $capture ]]; then
	pathdef="/root/move"
	export MIGDIR=$pathdef
	echo -en "${BG}${YELLOW}Files will be created at: ${RED} $MIGDIR ${NORMAL}" echo -e "\n"
	dircreate
		if [[ -d $path ]]; then
			yesnopopup
		fi
fi
echo -e "\n"
}
#divider
#divider
#divider
saveusers() {
export "UGIDLIMIT=500"
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > $path/passwd.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > $path/group.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > $path/shadow.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/group | tee - |egrep -f - /etc/gshadow > $path/gshadow.mig
pas=$(date|md5sum|cut -c 1-32)
timestamp=$(date|cut -c 12-19|sed s/://g)
zip -P $pas $path/userpack$timestamp.zip $path/*.mig*
dialog --backtitle 'UaGmt: USERS and GROUPS: moving tool' \
--title 'Files are packed' \
--msgbox "Files are packed to zip-archive with password: $pas Please copy this password to use on the destination server" 9 40
}
dumpusers() {
echo -en "${INVERSE}Type here the new path to save users and groups, \n ${INVERSE}default path is ${RED} [ /root/move ] ${NORMAL}${INVERSE} : ${NORMAL}" 
read -er capture
if [[ ! -z $capture ]]; then
	export path=$capture
	echo -en "${YELLOW}Files will be created at: ${RED} $path ${NORMAL}"
	echo -e "\n"

dircreate
elif [[ -z $capture ]]; then
	pathdef="/root/move"
	export path=$pathdef
	echo -en "${BG}${YELLOW}Files will be created at: ${RED} $path ${NORMAL}"
dircreate
fi
if [[ -d $path ]]; then
saveusers
filecount=$(find $path -type f -name '*.mig'|wc -l) 
echo -e "\n"
echo -en "${BG}${YELLOW}There are ${BLUE}$filecount .mig files located at: ${BG}${RED} $path ${NORMAL}" 
echo -e "\n \r"
fi
if [[ ! -d $path ]]; then
echo -en "${RED}Unfortunately system users and groups migration was FAILED...${NORMAL}" 
echo -e \n \r
fi
ls -la $path
}

#divider
menubox() {
$DIALOG --title "Please use SPACE to select" \
--radiolist "Direction of the migration:" 12 60 5 \
	"0" "Save users and groups on SRC" on \
	"1" "Restore users and groups on DST" off \
	"2" "Size of home dirs" off \
	"3" "RSync uploader" off \
	"4" "RSync downloader" off 2>$tempfile
#selected=$?
selected=`cat $tempfile`
case $selected in
	0) dumpusers;;
	1) restoreusers;;
	2) echo -en "Will be in the next releases!" "\n";;
	3) echo -en "Will be in the next releases!" "\n";;
	4) echo -en "Will be in the next releases!" "\n";;
	255) echo -en "[ESC] key pressed. exiting...";;
esac
}

#Finally, run!
menubox

exit 0
