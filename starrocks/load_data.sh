#!/bin/bash

# Load shared environment
source "$(dirname "$0")/env.sh"

# Check if the required arguments are provided
if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <DB_NAME> <TABLE_NAME> <MAX_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi


# Arguments
DATA_DIRECTORY="$1"
DB_NAME="$2"
TABLE_NAME="$3"
MAX_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"

# DB_HOST and DB_HTTP_PORT are provided by env.sh

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$MAX_FILES" =~ ^[0-9]+$ ]] && { echo "Error: MAX_FILES must be a positive integer."; exit 1; }

# Create a temporary directory for uncompressed files
#TEMP_DIR=$(mktemp -d /var/tmp/json_files.XXXXXX)
TEMP_DIR=$(mktemp -d ./tmp/json_files.XXXXXX)
trap "rm -rf $TEMP_DIR" EXIT  # Cleanup temp directory on script exit

# Load data
counter=0
concurrent_jobs=0
MAX_CONCURRENCY=20
pids=()

import_file() {
    local file="$1"
    local uncompressed_file="$2"
    local DB_NAME="$3"
    local TABLE_NAME="$4"
    local SUCCESS_LOG="$5"
    local ERROR_LOG="$6"

    # Decompress inside the function
    pigz -dc "$file" > "$uncompressed_file"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to uncompress $file" >> "$ERROR_LOG"
        return
    fi

    MAX_ATTEMPT=1
    attempt=0
    while [ $attempt -lt $MAX_ATTEMPT ]
    do
        http_code=$(curl -s -w "%{http_code}" -o >(cat >/tmp/curl_body_$$) \
            --location-trusted -u root: \
            -H "max_filter_ratio: 0.00001" \
            -H "strict_mode: true" \
            -H "Expect:100-continue" \
            -T "$uncompressed_file" \
            -XPUT http://${DB_HOST}:${DB_HTTP_PORT}/api/"$DB_NAME"/"$TABLE_NAME"/_stream_load)
        response_body="$(cat /tmp/curl_body_$$)"
        if jq -e . >/dev/null 2>&1 < /tmp/curl_body_$$; then
            response_status="$(jq -r '.Status' < /tmp/curl_body_$$)"
        else
            response_status=""
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Invalid JSON response for $file: $(cat /tmp/curl_body_$$)" >> "$ERROR_LOG"
        fi
        echo $response_status
        if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
            if [ "$response_status" = "Success" ]
            then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully imported $file. Response: $response_body" >> "$SUCCESS_LOG"
                rm -f "$uncompressed_file"  # Delete the uncompressed file after successful processing
                attempt=$((MAX_ATTEMPT))
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] $attempt attempt failed for $file with status code $http_code. Response: $response_body" >> "$ERROR_LOG"
                attempt=$((attempt + 1))
                sleep 2
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $attempt attempt failed for $file with status code $http_code. Response: $response_body" >> "$ERROR_LOG"
            attempt=$((attempt + 1))
            sleep 2
        fi
    done
}

for file in $(ls "$DATA_DIRECTORY"/*.json.gz | head -n "$MAX_FILES"); do
    echo "Processing file: $file"

    # Uncompress the file into the TEMP_DIR
    uncompressed_file="$TEMP_DIR/$(basename "${file%.gz}")"

    # Run import in background
    import_file "$file" "$uncompressed_file" "$DB_NAME" "$TABLE_NAME" "$SUCCESS_LOG" "$ERROR_LOG" &
    pids+=("$!")

    # Wait if we've hit the concurrency limit
    if [ "${#pids[@]}" -ge "$MAX_CONCURRENCY" ]; then
        wait
        pids=()
    fi

    counter=$((counter + 1))
    if [[ $counter -ge $MAX_FILES ]]; then
        break
    fi

done

# Wait for all remaining background jobs to finish
wait
