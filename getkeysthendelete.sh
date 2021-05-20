#!/bin/bash

# For output readability
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
COLOR_RESET=$(tput sgr0)
shopt -s globstar dotglob

cat << "ATTENTIONEOF"


 █████╗ ████████╗████████╗███████╗███╗   ██╗████████╗██╗ ██████╗ ███╗   ██╗
██╔══██╗╚══██╔══╝╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝██║██╔═══██╗████╗  ██║
███████║   ██║      ██║   █████╗  ██╔██╗ ██║   ██║   ██║██║   ██║██╔██╗ ██║
██╔══██║   ██║      ██║   ██╔══╝  ██║╚██╗██║   ██║   ██║██║   ██║██║╚██╗██║
██║  ██║   ██║      ██║   ███████╗██║ ╚████║   ██║   ██║╚██████╔╝██║ ╚████║
╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝


ATTENTIONEOF



echo "${RED}PLEASE MAKE A SAFE COPY OF YOUR SEEDS, PRIVATE KEYS AND MNEMONICS BELOW.  THIS MAY BE YOUR ONLY OPPORTUNITY BEFORE WE DELETE THEM FROM DISK!! DO NOT SHARE THEM WITH ANYONE! GO TO THE MENU BELOW AND CHOOSE AN OPTION ${COLOR_RESET}"



keyspath="keys.json"

seed=$(cat "$keyspath" | jq -r '.[].Seed')
pkey=$(cat "$keyspath" | jq -r '.[].PrivateKey')
mnemonic=$(cat "$keyspath" | jq -r '.[].Mnemonic')

echo "seed is: $seed"
echo "pkey is: $pkey"
echo "mnemonic if it exists is: $mnemonic"

echo "It is not good safety to leave these keys here in this file.  "




cat << "MENUEOF"

███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝

MENUEOF

PS3='Please choose 1, 2 or 3 from the menu to delete your keys if you have made a safe copy of them on an offline device or paper etc to minimise the chance of anyone coming across them: '
deletekeys="I HAVE MADE A COPY OF MY KEYS, PLEASE DELETE THE KEYS FILE"
leavekeys="DO NOT DELETE MY KEYS I WILL DO IT LATER"
cancelit="Cancel"
options=("$deletekeys" "$leavekeys" "$cancelit")
asktorestart=0
select opt in "${options[@]}"
do
    case $opt in
        "$deletekeys")
        action="delete"
        echo "You chose to delete the keys file"
        rm "keys.json"
         break
            ;;
        "$leavekeys")
            echo "You chose to leave the keys as you will delete them later"
        action="leave"
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
