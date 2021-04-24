#!/bin/bash

set -eu -o pipefail # fail on error , debug all lines

LOG_LOCATION=/root/
exec > >(tee -i $LOG_LOCATION/gcnode.log)
exec 2>&1


apt-get update -y && apt-get upgrade -y
#Install JQ which makes it easy to interpret JSON
apt-get update -y
apt-get install -y jq




# For output readability
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
COLOR_RESET=$(tput sgr0)

new_version_tag=$(curl -s https://api.github.com/repos/coti-io/coti-node/releases/latest | jq ".tag_name")
#Remove the front and end double quote
new_version_tag=${new_version_tag#"\""}
new_version_tag=${new_version_tag%"\""}
#new_version_tag=1.4.1 for example

echo "Latest version is $new_version_tag"

shopt -s globstar dotglob


cat << "MENUEOF"
███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
MENUEOF





PS3='Please choose what node you are installing today.  Mainnet or Testnet. Mainnet is by invite only so you will definitely know if it is mainnet you should be choosing. Please write the number of the menu item and press enter: '
mainnet="Install a node on to the COTI mainnet"
testnet="Install a node on to the COTI testnet"
cancelit="Cancel"
options=("$mainnet" "$testnet" "$cancelit")
asktorestart=0
select opt in "${options[@]}"
do
    case $opt in
        "$mainnet")
        action="mainnet"
        echo "You chose a mainnet node install"
        sleep 1
         break
            ;;
        "$testnet")
            echo "You chose a TESTNET node install"
        action="testnet"
        sleep 1
        break
            ;;
       "$cancelit")
            echo "${RED}You chose to cancel${COLOR_RESET}"
        action="cancel"
        exit 1
break
            ;;
        "Quit")
            exit 1
break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


echo "Welome to the COTI installer .  We will begin to ask you a series of questions.  Please have to hand:"
echo "✅ Your SSH Port No"
echo "✅ Your Ubuntu Username"
echo "✅ Your email address"
echo "✅ Your server hostname from Godaddy or namecheap etc e.g. coti.mynode.com"
echo "✅ Your wallet private key"
echo "✅ Your wallet seed key"
read -n 1 -r -s -p $'Press enter to begin...\n'

read -p "What is your ssh port number (likely 22 if you do not know)?: " portno
read -p "What is your ubuntu username (use coti if unsure as it will be created fresh) ?: " username
read -p "What is your email address?: " email
read -p "What is your server host name e.g. tutorialnode.cotinodes.com?: " servername
read -p "What is your wallet private key?: " pkey
read -p "What is your wallet seed?: " seed
read -p "What version node software would you like to use. Leave this empty and press enter to use latest version. If entering a version number, remember it takes this format: 1.4.1 ?: " new_version_tag_final


if [[ $new_version_tag_final == "" ]];
new_version_tag_final = $new_version_tag
then
echo "Using user supplied version: $new_version_tag_final"
fi

if [[ $portno == "" ]] || [[ $username == "" ]] || [[ $email == "" ]] || [[ $servername == "" ]] || [[ $pkey == "" ]] || [[ $seed == "" ]];
then
echo "Some details were not provided.  Script is now exiting.  Please run again and provide answers to all of the questions"
exit 1
fi


#Lets pad the seeds

function pad64chars(){
x=$1
while [ ${#x} -ne 64 ];
do
x="0"$x
done
echo "$x"
}

typeset -fx pad64chars
#Newly padded seed if needed
seed=$(pad64chars $seed)
#Newly padded private key if needed
pkey=$(pad64chars $pkey)

# padding of seeds and key complete



exec 3<>/dev/tcp/ipv4.icanhazip.com/80 
echo -e 'GET / HTTP/1.0\r\nhost: ipv4.icanhazip.com\r\n\r' >&3 
while read i
do
 [ "$i" ] && serverip="$i" 
done <&3 

serverurl=https://$servername

#########################################
# Create $username user if needed
#########################################

if id "$username" >/dev/null 2>&1; then
        echo "user exists"
else
        echo "user does not exist...creating"
        adduser --gecos "" --disabled-password $username
        adduser $username sudo



fi




apt-get update -y && sudo apt-get upgrade -y


echo "Installing prereqs..."
 sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

apt-get update -y && sudo apt-get upgrade -y


apt install openjdk-8-jdk maven nginx certbot python-certbot-nginx ufw nano git -y
java -version
mvn -version

ufw limit $portno
ufw allow 80
ufw allow 443
ufw allow 7070
ufw --force enable

cd /home/$username/
git clone https://github.com/coti-io/coti-fullnode.git
chown -R $username: /home/$username/coti-fullnode/
cd /home/$username/coti-fullnode/
sudo -u $username mvn initialize && sudo -u $username mvn clean compile && sudo -u $username mvn -Dmaven.test.skip=true package

cat <<EOF >/home/$username/coti-fullnode/fullnode.properties
network=TestNet
server.ip=$serverip
server.port=7070
server.url=$serverurl
application.name=FullNode
logging.file.name=FullNode1
database.folder.name=rocksDB1
resetDatabase=false
global.private.key=$pkey
fullnode.seed=$seed
minimumFee=0.01
maximumFee=100
fee.percentage=1
zero.fee.user.hashes=9c37d52ae10e6b42d3bb707ca237dd150165daca32bf8ef67f73d1e79ee609a9f88df0d437a5ba5a6cf7c68d63c077fa2c63a21a91fc192dfd9c1fe4b64bb959
kycserver.public.key=c10052a39b023c8d4a3fc406a74df1742599a387c58bcea2a2093bd85103f3bd22816fa45bbfb26c1f88a112f0c0b007755eb1be1fad3b45f153adbac4752638
kycserver.url=https://cca.coti.io
node.manager.ip=52.59.142.53
node.manager.port=7090
node.manager.propagation.port=10001
allow.transaction.monitoring=true
whitelist.ips=127.0.0.1,0:0:0:0:0:0:0:1
node.manager.public.key=2fc59886c372808952766fa5a39d33d891af69c354e6a5934a258871407536d6705693099f076226ee5bf4b200422e56635a7f3ba86df636757e0ae42415f7c2
EOF

FILE=/home/$username/coti-fullnode/FullNode1_clusterstamp.csv
if [ -f "$FILE" ]; then
    echo "$FILE already exists, no need to download"
else 
    echo "$FILE does not exist, downloading now"
    wget -q --show-progress --progress=bar:force 2>&1 https://www.dropbox.com/s/rpyercs56zmay0z/FullNode1_clusterstamp.csv -P /home/$username/coti-fullnode/
fi


#########################################
# Download Clusterstamp
#########################################

FILE=/home/$username/coti-fullnode/FullNode1_clusterstamp.csv
if [ -f "$FILE" ]; then
    echo "${YELLOW}$FILE already exists, no need to download the clusterstamp file ${COLOR_RESET}"
else
    echo "${YELLOW}$FILE does not exist, downloading the clusterstamp now... ${COLOR_RESET}"
    wget -q --show-progress --progress=bar:force 2>&1 https://www.dropbox.com/s/rpyercs56zmay0z/FullNode1_clusterstamp.csv -P /home/$username/coti-fullnode/
fi




chown $username /home/$username/coti-fullnode/FullNode1_clusterstamp.csv
chgrp $username /home/$username/coti-fullnode/FullNode1_clusterstamp.csv
chown $username /home/$username/coti-fullnode/fullnode.properties
chgrp $username /home/$username/coti-fullnode/fullnode.properties


certbot certonly --nginx --non-interactive --agree-tos -m $email -d $servername

cat <<'EOF' >/etc/nginx/sites-enabled/coti_fullnode.conf
server {
    listen      80;
    return 301  https://$host$request_uri;
}server {
    listen      443 ssl;
    listen [::]:443;
    server_name
    ssl_certificate
    ssl_key
    ssl_session_timeout 5m;
    gzip on;
    gzip_comp_level    5;
    gzip_min_length    256;
    gzip_proxied       any;
    gzip_vary          on;
    gzip_types
        text/css
        application/json
        application/x-javascript
        text/javascript
        application/javascript
        image/png
        image/jpg
        image/jpeg
        image/svg+xml
        image/gif
        image/svg;location  / {
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://127.0.0.1:7070;
    }
}
EOF

sed -i "s/server_name/server_name $servername;/g" /etc/nginx/sites-enabled/coti_fullnode.conf
sed -i "s:ssl_certificate:ssl_certificate /etc/letsencrypt/live/$servername/fullchain.pem;:g" /etc/nginx/sites-enabled/coti_fullnode.conf
sed -i "s:ssl_key:ssl_certificate_key /etc/letsencrypt/live/$servername/privkey.pem;:g" /etc/nginx/sites-enabled/coti_fullnode.conf

service nginx restart

cat <<EOF >/etc/systemd/system/cnode.service
[Unit]
Description=COTI Fullnode Service
[Service]
WorkingDirectory=/home/$username/coti-fullnode/
ExecStart=/usr/bin/java -Xmx256m -jar /home/$username/coti-fullnode/fullnode/target/fullnode-$new_version_tag_final.RELEASE.jar --spring.config.additional-location=fullnode.properties
SuccessExitStatus=143
User=$username
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cnode.service
systemctl start cnode.service
echo "Waiting for Coti Node to Start"
sleep 5
tail -f /home/$username/coti-fullnode/logs/FullNode1.log | while read line; do
echo $line  
echo ${GREEN}$line{COLOR_RESET}| grep -q 'COTI FULL NODE IS UP' && break;

done
sleep 2
echo "Your node is registered and running on the COTI Network"
