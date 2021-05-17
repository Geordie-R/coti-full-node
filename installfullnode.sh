#!/bin/bash

logging=false;

set -eu -o pipefail # fail on error , debug all lines




LOG_LOCATION=/root/


if [[ $logging == true ]];
then
echo "Logging turned on"
exec > >(tee -i $LOG_LOCATION/gcnode.log)
exec 2>&1
fi

apt-get update -y && apt-get upgrade -y
#Install JQ which makes it easy to interpret JSON
apt-get update -y
apt-get install -y jq










# For output readability
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
COLOR_RESET=$(tput sgr0)
new_version_tag_final=""
new_version_tag=$(curl -s https://api.github.com/repos/coti-io/coti-node/releases/latest | jq ".tag_name")
#Remove the front and end double quote
new_version_tag=${new_version_tag#"\""}
new_version_tag=${new_version_tag%"\""}
API_key=""
#new_version_tag=1.4.1 for example

echo "Latest version is $new_version_tag\n\n\n\n"

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










echo "Welcome to the COTI Node Installer .  We will begin to ask you a series of questions.  Please have to hand:"
echo "✅ Your SSH Port No"
echo "✅ Your Ubuntu Username"
echo "✅ Your email address"
echo "✅ Your server hostname from Godaddy or namecheap etc e.g. coti.mynode.com"
echo "✅ Your API Key if you are an exchange. If you are not an exchange, leave this empty."
echo "✅ Your wallet private key (if you are not an exchange)"
echo "✅ Your wallet seed key (if you are not an exchange)"

if [[ $action == "mainnet" ]];
then
echo "✅ What version of coti node you would like to use. Coti will communicate this to you. Write latest ONLY if they tell you to use latest commited version."
fi



read -n 1 -r -s -p $'Press enter to begin...\n'

read -p "What is your ssh port number (likely 22 if you do not know)?: " portno
read -p "What is your ubuntu username (use coti if unsure as it will be created fresh) ?: " username
read -p "What is your email address?: " email
read -p "What is your server host name e.g. tutorialnode.cotinodes.com?: " servername


read -p "Exchanges may be provided with an API key.  Please enter it now, or leave it empty and press enter if you are not an exchange:" API_key

# Ask for private key and seed if API key wasnt provided.
if [[ $API_key == "" ]] || [ -z "$API_key" ];
then

read -p "What is your wallet private key?: " pkey
read -p "What is your wallet seed?: " seed
else
pkey=""
seed=""
fi


extra_vers_desc=""
if [[ $action == "testnet" ]];
then
extra_vers_desc="If you leave this empty, it will use the latest version."
elif [[ $action == "mainnet" ]];
then
extra_vers_desc="If you leave this empty, the script will terminate."

fi


read -p "What version node software would you like to use. If you are on mainnet, or if you are an exchange, this should have been communicated to you from COTI. $extra_vers_desc. If entering a version number, remember it takes this format: 1.4.1 ?: " new_version_tag_final


# If we are on mainnet and a version isnt chosen, terminate the script
if [[ $action == "mainnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${RED}No version chosen.  Terminating script. ${COLOR_RESET}"
exit 1
elif [[ $action == "testnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${YELLOW}No version chosen, that's ok, selecting latest version.${COLOR_RESET}"
new_version_tag_final=$new_version_tag
fi


# Finally if the user wrote 'latest' then it will pull the latest version!
if [[ $new_version_tag_final == "latest" ]];
then
new_version_tag_final=$new_version_tag
fi



if [[ $portno == "" ]] || [[ $username == "" ]] || [[ $email == "" ]] || [[ $servername == "" ]];
then
echo "${RED}Some details were not provided.  Script is now exiting.  Please run again and provide answers to all of the questions${COLOR_RESET}"
exit 1
fi


if [[ $pkey == "" ]] || [[ $seed == "" ]] && [[ $API_key = "" ]];
then
echo "${RED}Private Key or Seed Key was not provided. Please run again and provide answers to all of the questions ${COLOR_RESET}"
exit 1
fi




if [[ $API_key != "" ]];
then

  # Its an exchange on mainnet.
  #sudo apt-get install unzip
  wget -O installkeygenerator.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/installkeygenerator.sh
  chmod +x installkeygenerator.sh
  working_dir=$(pwd);
  read -n 1 -r -s -p $'Press enter to run installkeygenerator.sh...\n'
  ./installkeygenerator.sh "$username"
  read -n 1 -r -s -p $'Press enter to run app.js...\n'
  node /home/$username/exchange-fullnode/app.js "$API_key" "$action" "" "$working_dir"

  read -n 1 -r -s -p $'Press enter to discover variables from keys.json...\n'

cat << "ATTENTIONEOF"

 █████╗ ████████╗████████╗███████╗███╗   ██╗████████╗██╗ ██████╗ ███╗   ██╗
██╔══██╗╚══██╔══╝╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝██║██╔═══██╗████╗  ██║
███████║   ██║      ██║   █████╗  ██╔██╗ ██║   ██║   ██║██║   ██║██╔██╗ ██║
██╔══██║   ██║      ██║   ██╔══╝  ██║╚██╗██║   ██║   ██║██║   ██║██║╚██╗██║
██║  ██║   ██║      ██║   ███████╗██║ ╚████║   ██║   ██║╚██████╔╝██║ ╚████║
╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
ATTENTIONEOF

echo "${RED}PLEASE MAKE A SAFE COPY OF YOUR KEYS BELOW.  THIS IS YOUR ONLY OPPORTUNITY BEFORE WE DELETE THEM FROM DISK!! DO NOT SHARE THEM WITH ANYONE! ${COLOR_RESET}"

read -n 1 -r -s -p $'Be prepared, press enter once to show you your seeds and private keys....\n'

seed=$(cat "$working_dir/keys.json" | jq '.Seed')
pkey=(cat "$working_dir/keys.json" | jq '.PrivateKey')
mnemonic=(cat "$working_dir/keys.json" | jq '.Mnemonic')

echo "SEED: $seed"
echo "PRIVATE KEY: $pkey"
echo "MNEMONIC: $mnemonic"

read -n 1 -r -s -p $'Press enter to confirm you have copied down your PRIVATE information above...\n'
rm $working_dir/keys.json
read -n 1 -r -s -p $'Now press enter once more to continue...\n'

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


if [[ $seed != "" ]];
then
#Newly padded seed if needed
seed=$(pad64chars $seed)
fi

if [[ $pkey != "" ]];
then
#Newly padded private key if needed
pkey=$(pad64chars $pkey)

fi
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


#IF mainnet lets download the dbrecovery and set db.restore to true!
if [[ $action == "mainnet" ]];
then
wget -O dbrecovery.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/v2.0/dbrecovery.sh
chmod +x dbrecovery.sh
./dbrecovery.sh "true" "$username"
fi






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

#IF mainnet lets set db.restore to false!
if [[ $action == "mainnet" ]];
then
./dbrecovery.sh "false" "$username"
fi

sleep 2
echo "Your node is registered and running on the COTI Network"
