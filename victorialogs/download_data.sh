#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <MAX_FILES>"
    exit 1
fi

# Arguments
DATA_DIRECTORY="$1"
MAX_FILES="$2"

PARALLEL_WORKERS=16

for i in $(seq -w 0001 $MAX_FILES); do
    wget https://clickhouse-public-datasets.s3.amazonaws.com/bluesky/file_${i}.json.gz -P $DATA_DIRECTORY -N -nv &
    [[ $(jobs -p -r | wc -l) -ge $PARALLEL_WORKERS ]] && wait -n
done

wait

echo "Finished downloading $MAX_FILES data files to $DATA_DIRECTORY"
