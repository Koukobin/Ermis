#!/bin/bash

# Define variables for folder and file paths
TARGET_FOLDER="$(git rev-parse --show-toplevel)/ErmisClient/Desktop"
JAR_FILE="$TARGET_FOLDER/target/mercury-client.jar"
LIB_FOLDER="$TARGET_FOLDER/target/lib"

SOURCE_FOLDER="$(git rev-parse --show-toplevel)/ErmisClient/Desktop"
TARGET_JAR="$SOURCE_FOLDER/target/mercury-client.jar"
LIB_FOLDER="$SOURCE_FOLDER/target/lib"
DOC_FILES=("README.md" "LICENSE.txt" "NOTICE.txt")

update_files () {
    INSTALL_FOLDER="$1"
    BIN="$INSTALL_FOLDER/bin"

    # Create necessary directories
    mkdir -p "$BIN/lib"

    # Copy the main JAR file and libraries
    cp "$JAR_FILE" "$BIN" || { echo "Failed to copy mercury-client.jar ($JAR_FILE)"; exit 1; }
    cp "$LIB_FOLDER"/* "$BIN/lib" || { echo "Failed to copy library files ($LIB_FOLDER)"; exit 1; }

    # Copy documentation files
    for file in "${DOC_FILES[@]}"; do
        cp "$TARGET_FOLDER/$file" "$INSTALL_FOLDER" || { echo "Failed to copy $file"; exit 1; }
    done
}

install_individual_jre() {
    cd $1
    if [[ -d $2 ]]; then
        echo "$3 is already installed"
    else
        wget "https://cdn.azul.com/zulu/bin/$2.tar.gz"
        tar -xzf "$2.tar.gz"
        rm "$2.tar.gz"
    fi
    cd -
}

create_deb_package() {
    sudo dpkg-deb --build $1 || { echo "Failed to build DEB package: $1"; exit 1; }
    echo "DEB package - $1 - succesfully created!"
}

AMD64_INSTALLER_PATH="mercury-client-installer_amd64"
ARM64_INSTALLER_PATH="mercury-client-installer_arm64"
ALL_INSTALLER_PATH="mercury-client-installer_all"

AMD64_OPT_PATH="$AMD64_INSTALLER_PATH/opt/Mercury-Client"
ARM64_OPT_PATH="$ARM64_INSTALLER_PATH/opt/Mercury-Client"
ALL_OPT_PATH="$ALL_INSTALLER_PATH/opt/Mercury-Client"

update_files $AMD64_OPT_PATH
update_files $ARM64_OPT_PATH
update_files $ALL_OPT_PATH

# Create DEB packages
install_individual_jre "$AMD64_OPT_PATH/jre"  "zulu17.40.19-ca-jre17.0.6-linux_x64" "x86-64 Zulu Java 17"
create_deb_package $AMD64_INSTALLER_PATH

install_individual_jre "$ARM64_OPT_PATH/jre"  "zulu21.42.19-ca-jre21.0.7-linux_aarch64" "AArch64 Zulu Java 21"
create_deb_package $ARM64_INSTALLER_PATH

create_deb_package $ALL_INSTALLER_PATH

echo "Succesfully created all DEB packages!"
