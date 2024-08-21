#!/bin/bash

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
    echo "You seem to have forgotten to add the Directory path"
    echo "Usage: $0 <directory>"
    echo 'Make sure to use " " at start/end of path'
    exit 1
fi

DIRECTORY=$1
OUTPUT_FILE="$DIRECTORY/file_names.csv"

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory $DIRECTORY does not exist."
    exit 1
fi

# Write the header to the CSV file
echo "Filename" > $OUTPUT_FILE

# Write the names of the files to the CSV file
for file in "$DIRECTORY"/*; 
do
    if [ -f "$file" ]; then
        echo "$(basename "$file")" >> $OUTPUT_FILE
    fi
done

echo "File names have been written to $OUTPUT_FILE"

