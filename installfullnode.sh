#!/bin/bash

logging=false


#If you turn logging on, be aware your gcnode.log may contain your keys!!

set -eu -o pipefail # fail on error , debug all lines

LOG_LOCATION=/root/
node_folder="coti-node"

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


function removequotes(){
  #Remove the front and end double quote
  version=${1#"\""}
  version=${version%"\""}
  echo "$version"
}

function lowercase(){
  echo $1 | awk '{print tolower($0)}'
}


new_version_tag_final=""
new_version_tag=$(curl -s https://api.github.com/repos/coti-io/$node_folder/releases/latest | jq ".tag_name")


#Remove the front and end double quote
new_version_tag=$(removequotes "$new_version_tag")
testnet_version="3.1.3"
API_key=""
coti_dir=""

echo "Latest version for mainnet is $new_version_tag"

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

#Make the servername lowercase
servername=$(lowercase $servername)

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

read -p "What version node software would you like to use. If you are on mainnet, or if you are an exchange, this should have been communicated to you from COTI. $extra_vers_desc. If entering a version number, remember it takes this format: 3.1.3 ?: " new_version_tag_final


# If we are on mainnet and a version isnt chosen, terminate the script
if [[ $action == "mainnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${RED}No version chosen.  Terminating script. ${COLOR_RESET}"
exit 1
elif [[ $action == "testnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${YELLOW}No version chosen, that's ok, selecting latest version.${COLOR_RESET}"
new_version_tag_final=$testnet_version
fi


# Finally if the user wrote 'latest' then it will pull the latest version!
if [[ $new_version_tag_final == "latest" ]];
then
new_version_tag_final=$new_version_tag
fi

echo "Chosen version is $new_version_tag_final"

if [[ $portno == "" ]] || [[ $username == "" ]] || [[ $email == "" ]] || [[ $servername == "" ]];
then
echo "${RED}Some details were not provided.  Script is now exiting.  Please run again and provide answers to all of the questions${COLOR_RESET}"
exit 1
fi


if [[ $pkey == "" ]] || [[ $seed == "" ]] && [[ $API_key = "" ]];
then
echo "Private Key or Seed Key was not provided. Please run again and provide answers to all of the questions"
exit 1
fi


#########################################
# Create $username user if needed (Recently Moved)
#########################################

if id "$username" >/dev/null 2>&1; then
        echo "user exists"
else
        echo "user does not exist...creating"
        adduser --gecos "" --disabled-password $username
        adduser $username sudo

fi

####################################
# Create keys , seeds and mnemonics
####################################

if [[ $API_key != "" ]];
then
  # Its an exchange on mainnet.
  #sudo apt-get install unzip
  wget -O installkeygenerator.sh "https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/installkeygenerator.sh"
  chmod +x installkeygenerator.sh
  working_dir=$(pwd)
  ./installkeygenerator.sh "$username"
echo "running app.js"

node /home/$username/exchange-fullnode/app.js "$API_key" "$action" "" "$(pwd)"

keyspath="$working_dir/keys.json"
echo "keyspath: $keyspath"

seed=$(cat "$keyspath" | jq -r '.[].Seed')
pkey=$(cat "$keyspath" | jq -r '.[].PrivateKey')
mnemonic=$(cat "$keyspath" | jq -r '.[].Mnemonic')

fi

#echo "passed fi"

#Lets pad the seeds

function pad64chars(){
x=$1
while [ ${#x} -ne 64 ];
do
x="0"$x
done
echo "$x"
}

if [[ $API_key == "" ]];
then

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
fi
# padding of seeds and key complete


exec 3<>/dev/tcp/ipv4.icanhazip.com/80
echo -e 'GET / HTTP/1.0\r\nhost: ipv4.icanhazip.com\r\n\r' >&3
while read i
do
 [ "$i" ] && serverip="$i"
done <&3

serverurl=https://$servername


apt-get update -y && sudo apt-get upgrade -y

echo "Installing prereqs..."
 sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

apt-get update -y && sudo apt-get upgrade -y

#curl -L -b "oraclelicense=a" -O https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm

wget -c https://coti.tips/downloads/jdk-8u291-linux-x64.tar.gz
mkdir -p /opt/java-jdk
tar -C /opt/java-jdk -zxf jdk-8u291-linux-x64.tar.gz
update-alternatives --install /usr/bin/java java /opt/java-jdk/jdk1.8.0_291/bin/java 1
update-alternatives --install /usr/bin/javac javac /opt/java-jdk/jdk1.8.0_291/bin/javac 1
echo "## JAVA VERSION START ##"
java -version
echo "## JAVA VERSION END ##"


echo "## Installing maven 3.5.4 START ##"
wget -c https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.4/apache-maven-3.5.4-bin.tar.gz
mkdir -p /opt/apache-maven-3.5.4/
tar -C /opt/ -zxf apache-maven-3.5.4-bin.tar.gz
echo "## Installing maven 3.5.4 END ##"

sudo ln -sf /opt/apache-maven-3.5.4 /opt/maven

if [[ ! -e /etc/profile.d/maven.sh ]]; then
echo "Creating /etc/profile.d/maven.sh"
    touch /etc/profile.d/maven.sh
fi

rm -f /etc/profile.d/maven.sh

echo "Creating environment variables in /etc/profile.d/maven.sh"
echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export MAVEN_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export PATH=/opt/maven/bin:$PATH" >> /etc/profile.d/maven.sh

chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
sleep 2
source /etc/profile.d/maven.sh
sleep 2
mvn -version


ubuntuvers=$(lsb_release -rs)
echo "Ubuntu version $ubuntuvers detected"
if [[ $ubuntuvers == "18.04" ]];
then
echo "Installing nginx certbot python-certbot-nginx ufw nano git..."
apt install nginx certbot python-certbot-nginx ufw nano git -y
else
echo "Installing nginx certbot python3-certbot-nginx ufw nano git..."
apt install nginx certbot python3-certbot-nginx ufw nano git -y
fi

ufw limit $portno
ufw allow 80
ufw allow 443

if [[ $action == "testnet" ]];
then
  ufw allow from 52.59.142.53 to any port 7070
elif [[ $action == "mainnet" ]];
then
  ufw allow from 35.157.47.86 to any port 7070
fi


ufw --force enable

cd /home/$username/

git clone --depth 1 --branch $new_version_tag_final https://github.com/coti-io/$node_folder/

chown -R $username: /home/$username/$node_folder/
cd /home/$username/$node_folder/
mvn initialize && mvn clean compile && mvn -Dmaven.test.skip=true package


logging_file_name="";

if [[ $action == "testnet" ]];
then

logging_file_name="FullNode1";
cat <<EOF-TESTNET >/home/$username/$node_folder/fullnode.properties
network=TestNet
server.ip=$serverip
server.port=7070
server.url=$serverurl
application.name=FullNode
logging.file.name=$logging_file_name
database.folder.name=rocksDB1
resetDatabase=false
global.private.key=$pkey
fullnode.seed=$seed
minimumFee=0.1
maximumFee=25
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
allow.transaction.monitoring=true
regular.token.fullnode.fee=1
reset.transactions=true
EOF-TESTNET

elif [[ $action == "mainnet" ]];
then
logging_file_name="FullNode1";
cat <<EOF-MAINNET >/home/$username/$node_folder/fullnode.properties
network=MainNet
server.ip=$serverip
server.port=7070
server.url=$serverurl
application.name=FullNode
logging.file.name=$logging_file_name
database.folder.name=rocksDB
global.private.key=$pkey
fullnode.seed=$seed
minimumFee=0.1
maximumFee=25
fee.percentage=0.1
zero.fee.user.hashes=
kycserver.public.key=c10052a39b023c8d4a3fc406a74df1742599a387c58bcea2a2093bd85103f3bd22816fa45bbfb26c1f88a112f0c0b007755eb1be1fad3b45f153adbac4752638
kycserver.url=https://cca.coti.io
node.manager.ip=35.157.47.86
node.manager.port=7090
node.manager.propagation.port=10001
node.manager.public.key=2fc59886c372808952766fa5a39d33d891af69c354e6a5934a258871407536d6705693099f076226ee5bf4b200422e56635a7f3ba86df636757e0ae42415f7c2
allow.transaction.monitoring=true
regular.token.fullnode.fee=1
EOF-MAINNET
fi

#IF mainnet lets download the dbrecovery and set db.restore to true!
if [[ $action == "mainnet" ]];
then
wget -O /home/$username/dbrecovery.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/dbrecovery.sh
chmod +x /home/$username/dbrecovery.sh
echo "Turning dbrecovery on"
/home/$username/dbrecovery.sh "true" "$username" "$action"
fi

echo "Moving on to clusterstamp"

#########################################
# Download Clusterstamp
#########################################

FILE=/home/$username/$node_folder/FullNode1_clusterstamp.csv

cluster_url_mainnet="https://coti.tips/downloads/FullNode1_clusterstamp.csv"
cluster_url_testnet="https://www.dropbox.com/s/rpyercs56zmay0z/FullNode1_clusterstamp.csv"

if [[ $action == "testnet" ]];
then
  echo "${YELLOW}Downloading the clusterstamp now from ... ${COLOR_RESET}"
  #wget "$FILE" $cluster_url_testnet
  wget --show-progress --progress=bar:force 2>&1 $cluster_url_testnet -P /home/$username/$node_folder/
elif [[ $action == "mainnet" ]];
then
echo "${YELLOW}Downloading the mainnet clusterstamp now from ... ${COLOR_RESET}"
#  wget "$FILE" $cluster_url_mainnet
  wget --show-progress --progress=bar:force 2>&1 $cluster_url_mainnet -P /home/$username/$node_folder/
fi

echo "Applying chgrp and chown to clusterstamp and properties"
chown $username /home/$username/$node_folder/FullNode1_clusterstamp.csv
chgrp $username /home/$username/$node_folder/FullNode1_clusterstamp.csv
chown $username /home/$username/$node_folder/fullnode.properties
chgrp $username /home/$username/$node_folder/fullnode.properties

echo "Moving on to NGINX"


#NGINX Setup

certbot certonly --nginx --non-interactive --agree-tos -m $email -d $servername
openssl dhparam -out /etc/nginx/dhparam.pem 2048

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
    ssl_protocols TLSv1.3 TLSv1.2;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    ssl_dhparam /etc/nginx/dhparam.pem;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    
    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 10s;
    
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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

echo "Doing SED commands to replace vars in /etc/nginx/sites-enabled/coti_fullnode.conf"

sed -i "s/server_name/server_name $servername;/g" /etc/nginx/sites-enabled/coti_fullnode.conf
sed -i "s:ssl_certificate:ssl_certificate /etc/letsencrypt/live/$servername/fullchain.pem;:g" /etc/nginx/sites-enabled/coti_fullnode.conf
sed -i "s:ssl_key:ssl_certificate_key /etc/letsencrypt/live/$servername/privkey.pem;:g" /etc/nginx/sites-enabled/coti_fullnode.conf
sed -i "s:ssl_trusted_certificate:ssl_trusted_certificate /etc/letsencrypt/live/$servername/chain.pem;:g" /etc/nginx/sites-enabled/coti_fullnode.conf


service nginx restart


#SYSTEMD service to run the node

cat <<EOF >/etc/systemd/system/cnode.service
[Unit]
Description=COTI Fullnode Service
[Service]
WorkingDirectory=/home/$username/$node_folder/
ExecStart=/usr/bin/java -jar /home/$username/$node_folder/fullnode/target/fullnode-$new_version_tag_final.RELEASE.jar --spring.config.additional-location=fullnode.properties
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
log_path="/home/$username/$node_folder/logs/$logging_file_name.log"
echo "Viewing $log_path #<#<#"
tail -f $log_path | while read line; do
echo $line
echo ${GREEN}$line${COLOR_RESET}| grep -q 'COTI FULL NODE IS UP' && break;

done

#IF mainnet lets set db.restore to false!
if [[ $action == "mainnet" ]];
then
echo "Turning dbrecovery off"
/home/$username/dbrecovery.sh "false" "$username" "$action"
fi
