#!/bin/bash

# json_reorganizer.sh - A script to alphabetically sort keys in a JSON file.
#
# --- Prerequisites ---
# This script requires 'jq' to be installed.
#
# --- Usage ---
# To use this script, run it with the path to your JSON file as an argument:
#   ./json_reorganizer.sh your_file.json
#
# The reorganized JSON will be printed to your console.
#
# I will admit shamefully - this script is AI generated...

if ! command -v jq &> /dev/null
then
    echo "Error: 'jq' is not installed."
    echo "Please install 'jq' using your package manager (e.g., sudo apt-get install jq or brew install jq)."
    exit 1
fi

# Check if a file path is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_json_file>"
    echo "Example: $0 mydata.json"
    exit 1
fi

# Get the input file path
INPUT_FILE="$1"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found at '$INPUT_FILE'"
    exit 1
fi

# Check if the input file is readable
if [ ! -r "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' is not readable. Check permissions."
    exit 1
fi

# Reorganize JSON keys alphabetically using jq
# The `sort_keys` filter sorts all keys in the JSON object recursively.
jq --sort-keys . "$INPUT_FILE"

# Check the exit status of jq
if [ $? -ne 0 ]; then
    echo "Error: Failed to process JSON file '$INPUT_FILE'."
    echo "Please ensure it is a valid JSON file."
    exit 1
fi

echo "JSON keys reorganized successfully for '$INPUT_FILE'."

