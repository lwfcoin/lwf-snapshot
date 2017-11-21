#!/bin/bash
###################
# Script made by Angelo Melis
# This script make a single snapshot of the current blockchain (testnet version)
# You can edit this file as you want.
###################

# USER MUST BE POSTGRES
# Location of the backup logfile.
logfile="/tmp/logfile.log"
# Location to place backups.
backup_dir="/opt/backups"
ENV="testnet"
WWW="/var/www/html/snapshots"
touch $logfile
export PGPASSWORD=your-psql-root-password
timeslot=`date +%H-%M`
databases=`psql -h localhost -U postgres -q -c "\l" | sed -n 4,/\eof/p | grep -v rows\) | awk {'print $1'} | grep -v "|" | grep -v template* | grep lwf`

for i in $databases; do
        timeinfo=`date '+%T %x'`
        pg_dump $i -Fp --no-acl --no-owner -h 127.0.0.1 | gzip > "$backup_dir/$i.gz"
	echo "DB Backup done at $timeslot" >> $logfile
done
cd $backup_dir

	if [ "$ENV" = "testnet" ]; then
cp /var/www/html/snapshots/testnet/latest /var/www/html/snapshots/testnet/latest.old
cp lwf_testnet.gz $WWW/testnet/latest
chmod 777 /var/www/html/snapshots/testnet/latest
echo "[Done: BRANCH $ENV]"
	elif [ "$ENV" = "main" ]; then
cp /var/www/html/snapshots/mainnet/latest /var/www/html/snapshots/testnet/latest.old
cp lwf_main.gz	$WWW/mainnet/latest
chmod 777 /var/www/html/snapshots/mainnet/latest
echo "[Done: BRANCH $ENV]"
	else
echo "Backup has been done but the Environment hasn't been recognized. Exit"
fi

#-------------------------------------------------
