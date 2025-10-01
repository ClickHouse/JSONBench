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

# Absolute path of Quickwit executable
QW_CMD="$PWD/quickwit"

echo "Prepare clean index: jsonbench"
$QW_CMD index create --index-config ./config/index-config.yaml --overwrite --yes

# Create a temporary directory for uncompressed files
TEMP_DIR=$(mktemp -d /var/tmp/json_files.XXXXXX)
trap "rm -rf $TEMP_DIR" EXIT  # Cleanup temp directory on script exit

pushd $DATA_DIRECTORY
counter=0
for file in $(ls *.json.gz | head -n $MAX_FILES); do
    echo "Processing file: $file"

    # Uncompress the file into the TEMP_DIR
    uncompressed_file="$TEMP_DIR/$(basename "${file%.gz}")"
    gunzip -c "$file" > "$uncompressed_file"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to uncompress $file" >> "$ERROR_LOG"
        continue
    fi

    $QW_CMD tool local-ingest \
        --index jsonbench \
        --input-path "$uncompressed_file"

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
popd

# See https://github.com/quickwit-oss/quickwit/issues/4869
echo "Wating 60 secs for Quickwit to commit the data"
sleep 60

$QW_CMD tool gc --index jsonbench

echo -e "\nLoaded $MAX_FILES data files from $DATA_DIRECTORY to Quickwit."
