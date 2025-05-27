#!/bin/bash

# Define the target Dart file or directory
TARGET_PATH="."

# List of constants to replace
declare -a CONSTANTS=(
    "applicationTitle"
    "applicationVersion"
    "appIconPath"
    "parthenonasPath"
    "sourceCodeURL"
    "licenceURL"
    "licencePath"
    "lightAppColors"
    "darkAppColors"
)

# Backup files before modification
find "$TARGET_PATH" -type f -name "*.dart" -exec cp {} {}.bak \;

# Loop through each constant and replace occurrences
for CONST in "${CONSTANTS[@]}"; do
    find "$TARGET_PATH" -type f -name "*.dart" -exec sed -i "s/\b$CONST\b/AppConstants.$CONST/g" {} +
done

echo "Refactoring complete! Backups are saved as .dart.bak files."

