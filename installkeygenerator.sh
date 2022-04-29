#!/bin/bash

function sha256checkpassed(){
  hash=$1
  filename=$2
  sha_check=$(echo "$hash $filename" | sha256sum -c | awk '{ print $2 }')
  echo $sha_check
}

#Args incoming
username=$1
path=/home/$username
filepath=$path/exchange-fullnode-coti.rar
wget -O $filepath "https://coti.tips/downloads/exchange-fullnode-coti.rar"

sha256var=$(cat exchange-fullnode-coti.rar.checksum)
sha_check=$(sha256checkpassed "$sha256var" "exchange-fullnode-coti.rar")

if [[ $sha_check == "OK" ]];
then
echo "exchange-fullnode-coti.rar sha hash nicely matches $sha256var!"
else
echo "exchange-fullnode-coti.rar SHA256 hash match failure!. File maybe compromised or developer has not updated new hash! For safety do not go any further and report this to https://t.me/GeordieR"
echo "ABORTED INSTALL!"
exit 1
fi

sudo apt install npm
sudo apt install unrar

unrar x -o+ $filepath $path

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

cd $path/exchange-fullnode
npm install
rm -rf $filepath 2> /dev/null
