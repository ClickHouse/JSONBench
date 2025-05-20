#!/bin/bash

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

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$MAX_FILES" =~ ^[0-9]+$ ]] && { echo "Error: MAX_FILES must be a positive integer."; exit 1; }

# Create a temporary directory for uncompressed files
TEMP_DIR=$(mktemp -d /var/tmp/json_files.XXXXXX)
trap "rm -rf $TEMP_DIR" EXIT  # Cleanup temp directory on script exit

# Load data
counter=0
start=0
for file in $(ls "$DATA_DIRECTORY"/*.json.gz | head -n "$MAX_FILES"); do
    echo "Processing file: $file"
    num=$(echo "$file" | sed -n 's/[^0-9]*\([0-9]\+\).*/\1/p')
    if [ "$num" -le "$start" ]; then
        continue
    fi

    # Uncompress the file into the TEMP_DIR
    uncompressed_file="$TEMP_DIR/$(basename "${file%.gz}")"
    gunzip -c "$file" > "$uncompressed_file"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to uncompress $file" >> "$ERROR_LOG"
        continue
    fi
    MAX_ATTEMPT=10
    attempt=0
    while [ $attempt -lt $MAX_ATTEMPT ]
    do
        # Attempt the import
        http_code=$(curl -s -w "%{http_code}" -o >(cat >/tmp/curl_body) --location-trusted -u root: -H "max_filter_ratio: 0.1" -H "Expect:100-continue" -H "columns: data" -T "$uncompressed_file" -XPUT http://127.0.0.1:8030/api/"$DB_NAME"/"$TABLE_NAME"/_stream_load)
        response_body="$(cat /tmp/curl_body)"
        response_status="$(cat /tmp/curl_body | jq -r '.Status')"
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

    counter=$((counter + 1))
    if [[ $counter -ge $MAX_FILES ]]; then
        break
    fi
done
