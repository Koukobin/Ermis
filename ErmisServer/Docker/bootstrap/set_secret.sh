#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Color reset

mkdir -p ./secrets

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
        echo -e "${RED}Please enter a valid number${NC}"
        continue
    fi

    if (( credential_to_set_index == last_index )); then
        exit 0
    fi

    if (( credential_to_set_index > last_index )); then
        echo -e "${RED}Index does not exist${NC}"
        continue
    fi

    credential_to_set=${my_array[$credential_to_set_index]}

    read -s -p "Enter password for '$credential_to_set' credential: " password
    printf '\n'
    read -s -p "Enter Password (again): " password2
    printf '\n'
    
    if [[ "$password" != "$password2" ]]; then
        echo -e "${RED}Passwords do not match${NC}"
        printf '\n'
        continue
    fi

    printf '%s' "$password" > ./secrets/"${credential_to_set}"
    chmod 600 ./secrets/"${credential_to_set}"
    echo -e "${BLUE}Saved.${NC}"
    printf '\n'
done
