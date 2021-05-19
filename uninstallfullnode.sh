#!/bin/bash
#Under construction for an uninstall file.
read -p "What is your ubuntu username (its likely to be coti if you followed the default suggestion on the install) ?: " username
rm -R /home/$username/coti-fullnode
