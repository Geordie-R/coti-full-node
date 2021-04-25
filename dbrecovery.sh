#!/bin/bash
#Args incoming
resetarg=$1

#Parameters
restore_hash_param=8eeae832927ed4a95cac73ede5c8b3082e6d3c16c5f98a97d6a7f3fa5b9c8ac364b5e7e8c1cf8d8b09bb23003e4029205d0946d676c6c907d6dccbe35dcbac7b
restore_source_param=Remote


read -p "What is your ubuntu username for coti node? (if unsure write coti) : " user_name
config_file="~/coti-fullnode/fullnode.properties"

function set_config_value(){
  #This replaces a key-pair value
  paramname=$(printf "%q" $1)
  paramvalue=$(printf "%q" $2)

  #echo $paramname
  #echo $paramvalue
  sed -i -E "s/^($paramname[[:blank:]]*=[[:blank:]]*).*/\1$paramvalue/" "$config_file"
}

#----------------------------------------------------------------------------------------------------#
# get_config_value: GLOBAL VALUE IS USED AS A GLOBAL VARIABLE TO RETURN THE RESULT                                     #
#----------------------------------------------------------------------------------------------------#

function get_config_value(){
  global_value=$(grep -v '^#' "$config_file" | grep "^$1=" | awk -F '=' '{print $2}')
if [ -z "$global_value" ]
  then
    return 1
  else
    return 0
  fi
}


reset=""
#DB.RESTORE ####################
# If entry does not exist, create it, otherwise set it to the value on the incoming argument
get_config_value "db.restore"
reset="$global_value"

if [[ $reset == "" ]];
then
echo db.restore=$resetarg >> $config_file
else
set_config_value "db.restore" "$resetarg"
fi


reset=""
#DB.RESTORE.SOURCE ####################
# If entry does not exist, create it, otherwise set it to the value on the restore_source_param parameter at the top of this file
get_config_value "db.restore.source"
reset="$global_value"

if [[ $reset == "" ]];
then
echo db.restore.source=$restore_source_param >> $config_file
else
set_config_value "db.restore.source" "$restore_source_param"
fi



reset=""
#DB.RESTORE.HASH ####################
# If entry does not exist, create it, otherwise set it to the value on the restore_hash_param parameter at the top of this file
get_config_value "db.restore.hash"
reset="$global_value"

if [[ $reset == "" ]];
then
echo db.restore.hash=$restore_hash_param >> $config_file
else
set_config_value "db.restore.hash" "$restore_hash_param"
fi


get_config_value "db.restore"

echo "db.restore is now set to $global_value"
