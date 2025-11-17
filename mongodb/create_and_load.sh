#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <DB_NAME> <COLLECTION_NAME> <DATA_DIRECTORY> <NUM_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

# Arguments
DB_NAME="$1"
COLLECTION_NAME="$2"
DATA_DIRECTORY="$3"
NUM_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$NUM_FILES" =~ ^[0-9]+$ ]] && { echo "Error: NUM_FILES must be a positive integer."; exit 1; }

# Create database and execute DDL file
mongosh --quiet --eval "
    db = db.getSiblingDB('$DB_NAME');
    load('$DDL_FILE');
"

echo "Loading data"
./load_data.sh "$DATA_DIRECTORY" "$DB_NAME" "$COLLECTION_NAME" "$NUM_FILES" "$SUCCESS_LOG" "$ERROR_LOG"
