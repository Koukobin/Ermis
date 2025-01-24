#!/bin/bash

# Define variables for folder and file paths
<<<<<<< HEAD
TARGET_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
JAR_FILE="$TARGET_FOLDER/target/ermis-server.jar"
LIB_FOLDER="$TARGET_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="ermis-server-installer/srv/ermis-server"
=======
SOURCE_FOLDER="$(git rev-parse --show-toplevel)/ErmisServer"
TARGET_JAR="$SOURCE_FOLDER/target/ErmisServer.jar"
LIB_FOLDER="$SOURCE_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE" "NOTICE")

INSTALL_FOLDER="Ermis-Server-installer/srv/Ermis-Server"
>>>>>>> 0c74aa7e80e490eb554aba98416b0a095873f561
BIN="$INSTALL_FOLDER/bin"

# Create necessary directories
mkdir -p "$BIN/lib"

# Copy the main JAR file and libraries
<<<<<<< HEAD
cp "$JAR_FILE" "$BIN" || { echo "Failed to copy ermis-server.jar"; exit 1; }
=======
cp "$TARGET_JAR" "$BIN" || { echo "Failed to copy ErmisServer.jar"; exit 1; }
>>>>>>> 0c74aa7e80e490eb554aba98416b0a095873f561
cp "$LIB_FOLDER"/* "$BIN/lib" || { echo "Failed to copy library files"; exit 1; }

# Copy documentation files
for file in "${DOC_FILES[@]}"; do
<<<<<<< HEAD
    cp "$TARGET_FOLDER/$file" "$INSTALL_FOLDER" || { echo "Failed to copy $file"; exit 1; }
done

# Create DEB package
sudo dpkg-deb --build ermis-server-installer || { echo "Failed to build DEB package"; exit 1; }
=======
    cp "$SOURCE_FOLDER/$file" "$INSTALL_FOLDER" || { echo "Failed to copy $file"; exit 1; }
done

# Create DEB package
sudo dpkg-deb --build Ermis-Server-installer || { echo "Failed to build DEB package"; exit 1; }
>>>>>>> 0c74aa7e80e490eb554aba98416b0a095873f561

echo "DEB package succesfully created!"
