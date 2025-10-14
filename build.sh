#!/bin/bash

# Build ErmisCommon, ErmisServer and ErmisClient/Desktop
mvn clean install

# Navigate to the mobile client directory
cd ErmisClient/Mobile/ermis_client/ || {
  echo "Failed to change directory to Ermis-Client/Mobile/ermis_client/"
  exit 1
}

chmod +x build.sh
./build.sh
