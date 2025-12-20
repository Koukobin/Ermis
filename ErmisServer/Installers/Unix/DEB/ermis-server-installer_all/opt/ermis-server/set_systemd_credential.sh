#!/bin/bash

declare -a my_array=("server_key-store_password" "db_user_password" "db_key-store_password" "emailer_password")
arraylength=${#my_array[@]}

# use for loop to read all values and indexes
for (( i = 0; i < ${arraylength}; i++ ));
do
  echo "$i. ${my_array[$i]}"
done

read -p "Choose credential to set: " credential_to_set_index

if [ $credential_to_set_index -ge $arraylength ]; then
    echo -e "\nIndex does not exist"
    exit 1
fi

credential_to_set=${my_array[$credential_to_set_index]}

read -s -p "Enter password for $credential_to_set credential: " password
echo -e "\n"

sudo echo "${password}" > "${credential_to_set}.txt"
sudo systemd-creds encrypt "${credential_to_set}.txt" "${credential_to_set}.cred"
sudo shred -u "${credential_to_set}.txt"
sudo install -m 600 "${credential_to_set}.cred" \
 /etc/ermis-server/
