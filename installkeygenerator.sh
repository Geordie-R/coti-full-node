#!/bin/bash

#Args incoming
username=$1
path=/home/$username
filepath=$path/exchange-fullnode-coti.rar
wget -O $filepath https://github.com/Geordie-R/coti-full-node/blob/New-API-Integration-v1/exchange-fullnode-coti.rar


sudo apt install npm
sudo apt install unrar

unrar x -o+ $filepath $path

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

cd $path/exchange-fullnode
npm install
rm $filepath
