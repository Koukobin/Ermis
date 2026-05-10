#!/bin/bash

declare -a my_array=("server_key-store_password" "db_user_password" "db_key-store_password" "emailer_password" "exit")
arraylength=${#my_array[@]}
last_index=$(( arraylength - 1 ))

while :; do
    # Use for loop to read all values and indices
    for (( i = 0; i < ${arraylength}; i++ ));
    do
      echo "$i. ${my_array[$i]}"
    done

    read -p "Choose credential to set: " credential_to_set_index

    if ! [[ "$credential_to_set_index" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid number"
        continue
    fi

    if (( credential_to_set_index == last_index )); then
        exit 0
    fi

    if (( credential_to_set_index > last_index )); then
        echo "Index does not exist"
        continue
    fi

    credential_to_set=${my_array[$credential_to_set_index]}

    read -s -p "Enter password for '$credential_to_set' credential: " password
    printf '\n'

    sudo printf '%s' "$password" > "${credential_to_set}.txt"
    sudo systemd-creds encrypt "${credential_to_set}.txt" "${credential_to_set}.cred"
    sudo shred -u "${credential_to_set}.txt"
    sudo install -m 600 "${credential_to_set}.cred" \
     /etc/ermis-server/
    echo "Saved."
done
