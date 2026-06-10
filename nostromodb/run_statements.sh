#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <data_path> <database_path> <query>"
    exit 1
fi

# Arguments
DATA_PATH="$1"
DATABASE_PATH="$2"
QUERY_TEXT="$3"

#echo "Running statement:" $QUERY_TEXT $DATA_PATH $DATABASE_PATH
docker run --ulimit nofile=65535:65535  -v "$DATA_PATH":/data -v "$DATABASE_PATH":/db svilenmihaylov/nostromodb --db_path /db/catalog.json --c "$QUERY_TEXT"
