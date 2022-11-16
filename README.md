# Auto-Updater

Auto-Updater is a Bash-Script who using SMB to get Files that need constantly Updated like Let's Encrypt Certificates who expires after 3 Months.


## Download

Use the package [git](https://github.com/git/git) to clone Auto-Updater.

```bash
git clone https://github.com/brueggli/auto-updater.git
```

## First thing First

Change the Variables in the Script for your own Wishes.


```bash
cd auto-updater
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


## Issues

If you have any Issues with the Script, Suggestions, Ideas or Improvements, create a Issue [here](https://github.com/brueggli/auto-updater/issues)

## License

[Apache License Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)
