# Auto-Updater

Auto-Updater is a Bash-Script who using SMB to get Files that need constantly Updated like Let's Encrypt Certificates who expires after 3 Months.

# Requirements
To run this Script successfully, only two Requirements are needed.
- sudo Package or root Access
- apt Package for Installing Programs
- Use of a Debian-System like Ubuntu

## Download

Use the package [git](https://github.com/git/git) to clone Auto-Updater.

```bash
git clone https://github.com/brueggli/auto-updater.git
cd auto-updater
```
or use wget to download the File
```bash
wget https://raw.githubusercontent.com/brueggli/auto-updater/main/auto-updater.sh
```
or use curl to write the Download-Content into a File
```bash
curl https://raw.githubusercontent.com/brueggli/auto-updater/main/auto-updater.sh -O
```

## First things First

Change the Variables in the Script for your own Wishes.


```bash
nano auto-updater.sh
```
Scroll down a little bit, then you find these Variables. Set it up to your Home Setup or maybe Remote Setup.
```bash
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
```
For the Password, create a File e.g /home/admin/.credentials
```bash
nano /home/admin/.credentials
```
and set the Password with password=...
```bash
password=DontusethisExamplePassword
```

# Run with Cron-Job
This Script is basically made for Use in a Cron-Job.
Setup a Cron-Job is really easy.
First, Open Cron-Job File with your Wish-Editor as root.
```bash
sudo crontab -e
```
Now, a couple of Editors shows up. Choose your Wish-Editor.
After choosing your Wish-Editor, a Cron-Job File Opens and you can set the Following to the End of the File.
```bash
59 01 1 * * bash /directory/auto-updater.sh
```
This Cron-Job runs the File at 01:59 in the Morning at the first day of every Month.

You can Calculate your Own Wish-Date under [crontab.guru](https://crontab.guru).

## Issues

If you have any Issues with the Script, Suggestions, Ideas or Improvements, create a Issue [here](https://github.com/brueggli/auto-updater/issues).

## License

[Apache License Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)
