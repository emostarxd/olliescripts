#!/bin/sh
#set +x
# Please confirm that you want to reset the MySQL passwords

action () {
# Kill any mysql processes currently running
        echo 'Shutting down any mysql processes...'
        service mysql stop
        killall -vw mysqld

        # Start mysql without grant tables
        mysqld_safe --skip-networking --skip-grant-tables >res 2>&1 &
        echo 'Resetting password... hold on'

        # Sleep for 5 while the new mysql process loads (if get a connection error you might need to increase this.)
        sleep 5

        # getting the password
        read -p "Paste your new root password: " DB_ROOT_PASS
        DB_ROOT_USER='root'
        # Update root user with new password
        mysql mysql -e "UPDATE user SET Password=PASSWORD('$DB_ROOT_PASS') WHERE User='$DB_ROOT_USER';FLUSH PRIVILEGES;"

        echo 'Cleaning up...'
        # Kill the insecure mysql process
        killall -v mysqld

        # Starting mysql again
        service mysql restart

        echo
        echo "Password reset has been completed"
        echo 
        echo "MySQL root password: $DB_ROOT_PASS"
        echo 
        echo "Remember to store this password safely!"
exit 0
}
CONFIRM="n"
read -p "Please confirm MySQL password reset. Continue? (y/N): " CONFIRM_INPUT

while true
do
        case $CONFIRM_INPUT in
        [yY]* ) action;;
		[nN]* ) exit;;
		* ) echo "Dude, just enter Y or N, please."; break ;;
		esac
done
