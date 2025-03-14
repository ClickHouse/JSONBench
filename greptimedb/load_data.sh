#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <MAX_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

# Arguments
DATA_DIRECTORY="$1"
MAX_FILES="$2"
SUCCESS_LOG="$3"
ERROR_LOG="$4"

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$MAX_FILES" =~ ^[0-9]+$ ]] && { echo "Error: MAX_FILES must be a positive integer."; exit 1; }

pushd $DATA_DIRECTORY
counter=0
for file in $(ls *.json.gz | head -n $MAX_FILES); do
    echo "Processing file: $file"

    curl "http://localhost:4000/v1/events/logs?table=jsontable&pipeline_name=jsonbench&ignore_errors=true" \
         -H "Content-Type: application/x-ndjson" \
         -H "Content-Encoding: gzip" \
         --data-binary @$file

    first_attempt=$?
    if [[ $first_attempt -eq 0 ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully imported $file." >> "$SUCCESS_LOG"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed for $file. Giving up." >> "$ERROR_LOG"
    fi

    counter=$((counter + 1))
    if [[ $counter -ge $MAX_FILES ]]; then
        break
    fi
done

curl -XPOST -H 'Content-Type: application/x-www-form-urlencoded' \
          http://localhost:4000/v1/sql \
          -d "sql=admin flush_table('jsontable')"

echo "Loaded $MAX_FILES data files from $DATA_DIRECTORY to greptimedb."
