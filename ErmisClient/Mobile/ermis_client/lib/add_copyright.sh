#!/bin/bash

# Define the copyright header
COPYRIGHT_HEADER="/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */"

# Function to add the header to a file
add_header() {
  local file="$1"
  
  # Check if the file already contains the copyright header
  if grep -q "Copyright (C) 2024 Ilias Koukovinis" "$file"; then
    echo "Skipping: $file (header already exists)"
    return
  fi

  if grep -q "Copyright (C) 2023 Ilias Koukovinis" "$file"; then
    echo "Skipping: $file (header already exists)"
    return
  fi

  if grep -q "Copyright (C) 2025 Ilias Koukovinis" "$file"; then
    echo "Skipping: $file (header already exists)"
    return
  fi
  
  # Add the header to the top of the file
  echo "Adding header to: $file"
  {
    echo "$COPYRIGHT_HEADER"
    echo
    cat "$file"
  } > temp_file && mv temp_file "$file"
}

# Find all files (you can adjust the file type filter as needed, e.g., *.java, *.dart, etc.)
find . -type f \( -name "*.java" -o -name "*.dart" -o -name "*.js" -o -name "*.py" \) | while read -r file; do
  add_header "$file"
done

