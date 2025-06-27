#!/bin/bash

# Define variables for folder and file paths
TARGET_FOLDER="$(git rev-parse --show-toplevel)/ErmisClient/Desktop"
JAR_FILE="$TARGET_FOLDER/target/ermis-client.jar"
LIB_FOLDER="$TARGET_FOLDER/target/lib"

SOURCE_FOLDER="$(git rev-parse --show-toplevel)/ErmisClient/Desktop"
TARGET_JAR="$SOURCE_FOLDER/target/ermis-client.jar"
LIB_FOLDER="$SOURCE_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE.txt" "NOTICE.txt")

INSTALL_FOLDER="Ermis-Client"
BIN="$INSTALL_FOLDER"

# Create necessary directories
mkdir -p "$BIN/lib"

# Copy the main JAR file and libraries
cp "$JAR_FILE" "." || { echo "Failed to copy ermis-client.jar ($JAR_FILE)"; exit 1; }
cp "$LIB_FOLDER"/* "$BIN/lib" || { echo "Failed to copy library files ($LIB_FOLDER)"; exit 1; }

# Copy documentation files
for file in "${DOC_FILES[@]}"; do
    cp "$TARGET_FOLDER/$file" "$INSTALL_FOLDER" || { echo "Failed to copy $file"; exit 1; }
done

echo "Files successfully updated!"
