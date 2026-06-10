#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <data_directory> <database_path> <table_name> <max_files>"
    exit 1
fi

# Arguments
DATA_DIR="$1"
DB_PATH="$2"
TABLE_NAME="$3"
MAX_FILES="$4"

# Validate that MAX_FILES is a number
if ! [[ "$MAX_FILES" =~ ^[0-9]+$ ]]; then
    echo "Error: <max_files> must be a positive integer."
    exit 1
fi

counter=0

# Loop through each .json.gz file in the directory
for file in $(ls "$DATA_DIR"/*.json.gz | sort); do
    echo "Progress:" $counter "of" $MAX_FILES "files loaded"

    if [[ -f "$file" ]]; then
        base_name=$(basename ${file})
        ./run_statements.sh "$DATA_DIR" "$DB_PATH" "import from '/data/$base_name' into $TABLE_NAME options {'NDJSON': true}"
        counter=$((counter + 1))
    fi

    # Stop processing if the max number of files is reached
    if [[ $counter -ge $MAX_FILES ]]; then
        echo "Copied maximum number of files: $MAX_FILES"
        break
    fi
done
