#!/bin/bash

# Use the current directory as the project directory
project_dir=$(pwd)

# Use a fixed name for the output file in the current directory
output_file="${project_dir}/code_context.txt"

# Check if the output file exists and remove it if it does
if [ -f "$output_file" ]; then
  rm "$output_file"
fi

# List of file types to ignore
ignore_files=("*.ico" "*.png" "*.jpg" "*.jpeg" "*.gif" "*.svg" "*.sh" "*.json")

# Folder to ignore
ignore_folder="node_modules"

# Function to check if a file should be ignored
should_ignore_file() {
  local file=$1
  for pattern in "${ignore_files[@]}"; do
    if [[ $file == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# Function to append file content to output file
append_file_content() {
  local file=$1
  relative_path=${file#"$project_dir/"}
  # shellcheck disable=SC2129
  echo "// File: $relative_path" >>"$output_file"
  cat "$file" >>"$output_file"
  echo -e "\n\n" >>"$output_file"
}

# Recursive function to read files and append their content
read_files() {
  for entry in "$1"/*; do
    if [ -d "$entry" ]; then
      # Skip the directory if it is the one to be ignored
      if [[ $(basename "$entry") == "$ignore_folder" ]]; then
        continue
      fi
      # If entry is a directory, call this function recursively
      read_files "$entry"
    elif [ -f "$entry" ]; then
      # Check if the file type should be ignored
      if ! should_ignore_file "$entry"; then
        append_file_content "$entry"
      fi
    fi
  done
}

# Start processing from the project directory
read_files "$project_dir"
