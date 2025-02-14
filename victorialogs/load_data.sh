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

# Load data
PARALLEL_WORKERS=8
counter=0
for file in $(ls "$DATA_DIRECTORY"/*.json.gz | head -n "$MAX_FILES"); do
    echo "Processing file: $file"

    zcat $file | curl -s --fail -T - -X POST 'http://localhost:9428/insert/jsonline?_time_field=time_us&_stream_fields=kind,commit.collection,commit.operation' \
        && echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully imported $file." >> "$SUCCESS_LOG" \
        || echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed importing $file." >> "$ERROR_LOG" &

    [[ $(jobs -p -r | wc -l) -ge $PARALLEL_WORKERS ]] && wait -n

    counter=$((counter + 1))
    if [[ $counter -ge $MAX_FILES ]]; then
        break
    fi
done

wait

echo "Loaded $MAX_FILES data files from $DATA_DIRECTORY to victorialogs."
