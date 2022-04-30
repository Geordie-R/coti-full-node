#!/bin/bash
read -p "What is your ubuntu username (its likely to be coti if you followed the default suggestion on the install) ?: " username
propertiesfile="/home/$username/coti-fullnode/fullnode.properties"
read -p "Would you like to keep your fullnode.properties file containing seed, private key, host settings etc to enable a faster reinstall? It will be saved into /home/$username until your reinstall is completed, then it will be removed. Type y for yes or n for no:" keepfile

if [[ $keepfile == "y" ]];
then
cp $propertiesfile "/home/$username/"
fi

rm -R /home/$username/coti-fullnode 2> /dev/null
rm -R /home/$username/coti-node 2> /dev/null
systemctl stop cnode.service 2> /dev/null
systemctl disable cnode.service 2> /dev/null
rm /etc/systemd/system/cnode.service 2> /dev/null
rm /usr/lib/systemd/system/cnode.service 2> /dev/null
systemctl daemon-reload
systemctl reset-failed
echo "Uninstall Completed"
