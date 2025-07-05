#!/bin/sh

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

    if [ -n "$JAVA_HOME" ]; then
      sudo $JAVA_HOME/bin/java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
    else
      sudo java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
    fi

    sudo turnserver --log-file stdout --tls-listening-port=5439 --listening-port=5440
}

create_folder_backup_and_restore_once_process_dies () {
    touch /tmp/session.keepalive # File denoting process is active

    kill_file_denoting_process_is_alive() {
        rm -f /tmp/session.keepalive # Kill file denoting process is active
    }

    trap kill_file_denoting_process_is_alive EXIT
    # UPPERCASE IS CRUCIAL SINCE THE VARIABLES NOW ARE GLOBAL AND THE TRAP WORKS
    FOLDER="$1/"
    BACKUP="$1_backup/"

    restore_backup() {
        echo "\nRestoring original folder: $BACKUP -> $FOLDER ..."
        sudo rm -rf "$FOLDER"
        sudo cp -r "$BACKUP" "$FOLDER"
        sudo chmod -R 777 "$FOLDER"
        sudo rm -rf "$BACKUP"
    }
    
    # If backup exists then perform cleanup
    if [ -d "$BACKUP" ]; then
        restore_backup
    fi

    (
        while [ -f /tmp/session.keepalive ]; do
            sleep 1
        done

        echo "Parent shell died. Exiting subshell."
        trap restore_backup EXIT INT TERM
    ) &

    # Copy the original directory to a backup location
    sudo cp -r --no-preserve=ownership "$FOLDER" "$BACKUP"

    echo "Created backup for server folder $FOLDER -> $BACKUP..."

    # Folder automatically restored by subshell above
}

create_folder_backup_and_restore_once_process_dies "/var/ermis-server/www"
create_folder_backup_and_restore_once_process_dies "/etc/nginx"

debute_server
