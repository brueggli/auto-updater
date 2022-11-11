#!/bin/bash

#The script is made to interact with SMB fileshare server
#The script works with docker container who includes Files that need to be updated automatically like Let's Encrypt certificates who expire after 3 months
#When this files get placed in a shared SMB location, this script is the thing what you need

LOG_FILE="auto-updater-"$(date +%Y_%m_%d_%I_%M_%S)".log"
LOG_DIR="/var/log/auto-updater"

#ERROR_CODE meaning:
#ERROR_CODE 1 = everyting is fine, script was successful
#ERROR_CODE 2 = no root permission
#ERROR_CODE 3 = MOUNT_DIR is already mounted
#ERROR_CODE 4 = MOUNT_DIR is already existing
#ERROR_CODE 5 = mounting smb to MOUNT_DIR failed
#ERROR_CODE 6 = Docker Container still running
#ERROR_CODE 7 = Docker Container failed to starting
#ERROR_CODE 8 = Unmounting $MOUNT_DIR failed

#======================================

#These packages are required by the script

RQ_PKG1="samba"
RQ_PKG2="cifs-utils"
RQ_PKG3="openssl"
RQ_PKG4="mount"
RQ_PKG5="docker-compose-plugin"

#======================================

#These variables are required by the script to places the files in the right folder and interact with the SMB-server

SMB_IP="SMB_IP"
SMB_SHAREFOLDER="cert"
USER="SMB_USER"
DOMAIN="WORKGROUP"
MOUNT_DIR="/mnt/cert"
CONTAINER_ROOT_DIR="/opt/docker-container"
WEBSERVER_CERT_DIR="/opt/docker-container/webserver/certs"
FILE_PERMISSION="400"
FILE1="chain.pem"
FILE2="crt.pem"
FILE3="key.pem"
CREDENTIALS="/home/admin/.credentials"

#======================================

#Checking for root permission

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
	ERROR_CODE="2"
	echo "Not running as root! Exit with ERROR CODE $ERROR_CODE..."
	exit $ERROR_CODE
fi

#======================================

if [ -d "$LOG_DIR" ]; then
	touch $LOG_DIR/$LOG_FILE
else
	mkdir $LOG_DIR
	touch $LOG_DIR/$LOG_FILE
fi

#======================================

#Checks if the required packages are installed, if not, they will be installed

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $RQ_PKG1|grep "install ok installed")
echo Checking for $RQ_PKG1: $PKG_OK >>$LOG_DIR/$LOG_FILE
if [ "" = "$PKG_OK" ]; then
	echo "No $RQ_PKG1. Setting up $RQ_PKG1." >>$LOG_DIR/$LOG_FILE
	sudo apt --yes update >>$LOG_DIR/$LOG_FILE
	sudo apt --yes install $RQ_PKG1 >>$LOG_DIR/$LOG_FILE
	echo "Package $RQ_PKG1 successfuly installed." >>$LOG_DIR/$LOG_FILE
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $RQ_PKG2|grep "install ok installed")
echo Checking for $RQ_PKG2: $PKG_OK >>$LOG_DIR/$LOG_FILE
if [ "" = "$PKG_OK" ]; then
	echo "No $RQ_PKG2. Setting up $RQ_PKG2." >>$LOG_DIR/$LOG_FILE
	sudo apt --yes update >>$LOG_DIR/$LOG_FILE
	sudo apt --yes install $RQ_PKG2 >>$LOG_DIR/$LOG_FILE
	echo "Package $RQ_PKG2 successfuly installed." >>$LOG_DIR/$LOG_FILE
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $RQ_PKG3|grep "install ok installed")
echo Checking for $RQ_PKG3: $PKG_OK >>$LOG_DIR/$LOG_FILE
if [ "" = "$PKG_OK" ]; then
	echo "No $RQ_PKG3. Setting up $RQ_PKG3." >>$LOG_DIR/$LOG_FILE
	sudo apt --yes update >>$LOG_DIR/$LOG_FILE
	sudo apt --yes install $RQ_PKG3 >>$LOG_DIR/$LOG_FILE
	echo "Package $RQ_PKG3 successfuly installed." >>$LOG_DIR/$LOG_FILE
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $RQ_PKG4|grep "install ok installed")
echo Checking for $RQ_PKG4: $PKG_OK >>$LOG_DIR/$LOG_FILE
if [ "" = "$PKG_OK" ]; then
	echo "No $RQ_PKG4. Setting up $RQ_PKG4." >>$LOG_DIR/$LOG_FILE
	sudo apt --yes update >>$LOG_DIR/$LOG_FILE
	sudo apt --yes install $RQ_PKG4 >>$LOG_DIR/$LOG_FILE
	echo "Package $RQ_PKG4 successfuly installed." >>$LOG_DIR/$LOG_FILE
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $RQ_PKG5|grep "install ok installed")
echo Checking for $RQ_PKG5: $PKG_OK >>$LOG_DIR/$LOG_FILE
if [ "" = "$PKG_OK" ]; then
	echo "No $RQ_PKG5. Setting up $RQ_PKG5." >>$LOG_DIR/$LOG_FILE
	sudo apt --yes update >>$LOG_DIR/$LOG_FILE
	sudo apt --yes install $RQ_PKG5 >>$LOG_DIR/$LOG_FILE
	echo "Package $RQ_PKG5 successfuly installed." >>$LOG_DIR/$LOG_FILE
fi

#======================================

#Rest of the Script

if findmnt $MOUNT_DIR >>$LOG_DIR/$LOG_FILE; then
	ERROR_CODE="3"
	echo "$MOUNT_DIR is already mounted!" >>$LOG_DIR/$LOG_FILE
	echo "Unmount $MOUNT_DIR and delete the folder if possible or change the MOUNT_DIR variable at the beginning of the script. Exit with ERROR CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "$MOUNT_DIR is already mounted!"
	echo "Unmount $MOUNT_DIR and delete the folder if possible or change the MOUNT_DIR variable at the beginning of the script. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
fi

if [ -d "$MOUNT_DIR" ]; then
	ERROR_CODE="4"
	echo "Folder $MOUNT_DIR is already existing!" >>$LOG_DIR/$LOG_FILE
	echo "Please delete the folder or change the MOUNT_DIR variable at the beginning of the script. Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "Folder $MOUNT_DIR is already existing!"
	echo "Please delete the folder or change the MOUNT_DIR variable at the beginning of the script. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
fi

mkdir $MOUNT_DIR
mount.cifs //$SMB_IP/$SMB_SHAREFOLDER -o credentials=$CREDENTIALS,username=$USER,domain=$DOMAIN $MOUNT_DIR >>$LOG_DIR/$LOG_FILE

if findmnt $MOUNT_DIR >>$LOG_DIR/$LOG_FILE; then
	echo "Mounted //$SMB_IP/$SMB_SHAREFOLDER successfuly to $MOUNT_DIR" >>$LOG_DIR/$LOG_FILE
else
	ERROR_CODE="5"
	rm -r $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	echo "Mounting //$SMB_IP/$SMB_SHAREFOLDER to $MOUNT_DIR failed!" >>$LOG_DIR/$LOG_FILE
	echo "Please check your SMB server and your mounting configuration and your login credentials. Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "Mounting //$SMB_IP/$SMB_SHAREFOLDER to $MOUNT_DIR failed!"
	echo "Please check your SMB server and your mounting configuration and your login credentials. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
fi

cd $CONTAINER_ROOT_DIR
docker compose down >>$LOG_DIR/$LOG_FILE
CONTAINER_RUNNING_CHECK=$(sudo docker compose ps -a | grep "running")

if [ "" = "$CONTAINER_RUNNING_CHECK" ]; then
	echo "Docker Container shutdown successfuly." >>$LOG_DIR/$LOG_FILE
else
	ERROR_CODE="6"
	umount $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	rm -r $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	echo "Docker Container still running" >>$LOG_DIR/$LOG_FILE
	echo "Check logs and Docker for Errors. Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "Docker Container still running"
	echo "Check logs and Docker for Errors. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
fi

rm $WEBSERVER_CERT_DIR/$FILE1 >>$LOG_DIR/$LOG_FILE
rm $WEBSERVER_CERT_DIR/$FILE2 >>$LOG_DIR/$LOG_FILE
rm $WEBSERVER_CERT_DIR/$FILE3 >>$LOG_DIR/$LOG_FILE
cp $MOUNT_DIR/$FILE1 $WEBSERVER_CERT_DIR >>$LOG_DIR/$LOG_FILE
cp $MOUNT_DIR/$FILE2 $WEBSERVER_CERT_DIR >>$LOG_DIR/$LOG_FILE
cp $MOUNT_DIR/$FILE3 $WEBSERVER_CERT_DIR >>$LOG_DIR/$LOG_FILE
chmod -c -R $FILE_PERMISSION $WEBSERVER_CERT_DIR/$FILE1 >>$LOG_DIR/$LOG_FILE
chmod -c -R $FILE_PERMISSION $WEBSERVER_CERT_DIR/$FILE2 >>$LOG_DIR/$LOG_FILE
chmod -c -R $FILE_PERMISSION $WEBSERVER_CERT_DIR/$FILE3 >>$LOG_DIR/$LOG_FILE

docker compose up -d >>$LOG_DIR/$LOG_FILE
CONTAINER_RUNNING_CHECK=$(sudo docker compose ps -a | grep "running")

if [ "" = "$CONTAINER_RUNNING_CHECK" ]; then
	ERROR_CODE="7"
	umount $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	rm -r $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	echo "Start of Docker Container failed." >>$LOG_DIR/$LOG_FILE
	echo "Please check logs and the Docker Container itself. Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "Start of Docker Container failed."
	echo "Please check logs and the Docker Container itself. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
else
	echo "Docker Container started successfuly." >>$LOG_DIR/$LOG_FILE
fi

umount $MOUNT_DIR >>$LOG_DIR/$LOG_FILE

if findmnt $MOUNT_DIR >>$LOG_DIR/$LOG_FILE; then
	ERROR_CODE=8
	rm -r $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
	echo "Umounting of $MOUNT_DIR failed." >>$LOG_DIR/$LOG_FILE
	echo "Please check logs for Errors. Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
	echo "Logfile: $LOG_DIR/$LOG_FILE"
	echo ""
	echo "Unmounting of $MOUNT_DIR failed."
	echo "Please check logs for Errors. Exit with ERROR_CODE $ERROR_CODE..."
	exit $ERROR_CODE
else
	echo "Unmounting of $MOUNT_DIR successfuly." >>$LOG_DIR/$LOG_FILE
fi

rm -r $MOUNT_DIR >>$LOG_DIR/$LOG_FILE
ERROR_CODE="1"
echo "Logfile: $LOG_DIR/$LOG_FILE"
echo ""
echo "Script was successfuly executed." >>$LOG_DIR/$LOG_FILE
echo "No Errors found. If a Error still accurred, check logfile." >>$LOG_DIR/$LOG_FILE
echo "Exit with ERROR_CODE $ERROR_CODE..." >>$LOG_DIR/$LOG_FILE
echo "Script was successfuly executed."
echo "No Errors found. If a Error still accurred, check logfile."
echo "Exit with ERROR_CODE $ERROR_CODE..."
exit $ERROR_CODE

#======================================
#EOF
