#!/bin/bash

# Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

FOLDERS_TO_BACKUP=("/var/ermis-server/www" "/etc/nginx")

declare -A BACKUP_FOLDERS
for folder in "${FOLDERS_TO_BACKUP[@]}"; do
    BACKUP_FOLDERS[$folder]="${folder}_${$}_back"
done

debute_server () {
    chmod +x apply_server_settings.pl
    sudo ./apply_server_settings.pl

    # Attempt to find server JAR file
    ERMIS_SERVER_JAR_FILE=$(find bin -maxdepth 1 -name "*.jar" -print -quit)

    # Check if a JAR file was found
    if [ -z "$ERMIS_SERVER_JAR_FILE" ]; then
      echo "No JAR file found in the directory!"
      exit 1
    fi

    VM_ARGUMENTS="
        -Djava.security.egd=file:/dev/./urandom 
        -server 
        -XX:+UseZGC 
        --add-opens java.base/java.lang=ALL-UNNAMED 
        --add-opens java.base/jdk.internal.misc=ALL-UNNAMED
        --add-opens java.base/java.nio=ALL-UNNAMED
        -Dio.netty.tryReflectionSetAccessible=true
        -Dfile.encoding=UTF-8"
    PROGRAM_ARGUMENTS=""

    (
        turnserver --log-file stdout --tls-listening-port=5439 --listening-port=5440
    ) &
    TURN_SERVER_PID+=($!)

    if [ -n "$JAVA_HOME" ]; then
      $JAVA_HOME/bin/java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
    else
      java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
    fi

    kill "$TURN_SERVER_PID" # Kill turnserver process once Java server dies
}

restore_backup_folders() {
    restore_folder() {
        folder="$1"
        backup_folder="$2"
        echo -e "\nRestoring original folder: $backup_folder -> $folder ..."
        sudo rm -rf "$folder"
        sudo cp -r "$backup_folder" "$folder"
        sudo chmod -R 700 "$folder"
        sudo rm -rf "$backup_folder"
    }

    if [ -z "$1" ] && [ -z "$2" ]; then
        restore_folder $1 $2
        return
    fi
    
    for folder in "${FOLDERS_TO_BACKUP[@]}"; do
        backup_folder="${BACKUP_FOLDERS[$folder]}"
        restore_folder $folder $backup_folder
    done
}

create_backup_folders() {
    for folder in "${FOLDERS_TO_BACKUP[@]}"; do
        backup_folder="${BACKUP_FOLDERS[$folder]}"
        
        # If backup exists then perform cleanup
        if [ -d "$backup_folder" ]; then
            restore_backup $folder $backup_folder
        fi

        # Copy the original directory to a backup location
        sudo cp -r --no-preserve=ownership "$folder" "$backup_folder"

        echo "Created backup for server folder $folder -> $backup_folder..."

        # Folder automatically restored by trap
    done
}

create_backup_folders
trap restore_backup_folders EXIT

debute_server
