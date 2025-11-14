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
./quickwit index create --index-config ./config/index-config.yaml --overwrite --yes

pushd $DATA_DIRECTORY
counter=0
for file in $(ls *.json.gz | head -n $MAX_FILES); do
    gunzip -c "$file"

    counter=$((counter + 1))
    if [[ $counter -ge $MAX_FILES ]]; then
        break
    fi
done | $QW_CMD tool local-ingest --index jsonbench
popd

# See https://github.com/quickwit-oss/quickwit/issues/4869
echo "Wait 1 min for Quickwit search become available"
sleep 60

./quickwit tool gc --index jsonbench

echo -e "\nLoaded $MAX_FILES data files from $DATA_DIRECTORY to Quickwit."
