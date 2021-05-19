#!/bin/bash
read -p "What is your ubuntu username (its likely to be coti if you followed the default suggestion on the install) ?: " username
rm -R /home/$username/coti-fullnode
systemctl stop cnode.service
systemctl disable cnode.service
rm /etc/systemd/system/cnode.service 2> /dev/null
rm /usr/lib/systemd/system/cnode.service 2> /dev/null
systemctl daemon-reload
systemctl reset-failed
