#!/bin/bash

# Define variables for folder and file paths
TARGET_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
JAR_FILE=$(find "$TARGET_FOLDER/target" -maxdepth 1 -name "*.jar") # Search for JAR file
LIB_FOLDER="$TARGET_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="ermis-server-installer/srv/ermis-server"

SOURCE_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
TARGET_JAR="$SOURCE_FOLDER/target/ErmisServer.jar"
LIB_FOLDER="$SOURCE_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="ermis-server-installer/opt/ermis-server"
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
sudo dpkg-deb --build ermis-server-installer || { echo "Failed to build DEB package"; exit 1; }

echo "DEB package succesfully created!"
