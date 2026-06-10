#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <DB_PATH> <TABLE_NAME> <DATA_DIRECTORY> <NUM_FILES>"
    exit 1
fi

# Arguments
DB_PATH="$1"
TABLE_NAME="$2"
DATA_DIRECTORY="$3"
NUM_FILES="$4"

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error in create_and_load: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$NUM_FILES" =~ ^[0-9]+$ ]] && { echo "Error in create_and_load: NUM_FILES must be a positive integer."; exit 1; }

# No need to issue explicit 'create table', just load the data...
echo "Load data"
./load_data.sh "$DATA_DIRECTORY" "$DB_PATH" "$TABLE_NAME" "$NUM_FILES"
