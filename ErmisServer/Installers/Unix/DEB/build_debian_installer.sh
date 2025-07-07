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

# Define variables for folder and file paths
TARGET_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
JAR_FILE=$(find "$TARGET_FOLDER/target" -maxdepth 1 -name "*.jar") # Search for JAR file
LIB_FOLDER="$TARGET_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="ermis-server-installer_all/srv/ermis-server"

SOURCE_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
TARGET_JAR="$SOURCE_FOLDER/target/ErmisServer.jar"
LIB_FOLDER="$SOURCE_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="ermis-server-installer_all/opt/ermis-server"
BIN="$INSTALL_FOLDER/bin"

# Create necessary directories
mkdir -p "$BIN/lib"

# Copy the main JAR file and libraries
cp "$JAR_FILE" "$BIN" || { echo "Failed to copy ermis-server.jar"; exit 1; }
cp "$LIB_FOLDER"/* "$BIN/lib" || { echo "Failed to copy library files"; exit 1; }

# Copy documentation files
for file in "${DOC_FILES[@]}"; do
    cp "$TARGET_FOLDER/$file" "$INSTALL_FOLDER" || { echo "Failed to copy $file"; exit 1; }
done

# Create DEB package
chmod 755 ermis-server-installer_all/DEBIAN/ && chmod 755 ermis-server-installer_all/DEBIAN/* # Ensure correct permissions
sudo dpkg-deb --build ermis-server-installer_all || { echo "Failed to build DEB package"; exit 0; }

echo "DEB package succesfully created!"
