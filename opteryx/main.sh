#!/bin/bash

DEFAULT_CHOICE=ask
DEFAULT_DATA_DIRECTORY=~/data/bluesky

# Allow the user to optionally provide the scale factor ("choice") as an argument
CHOICE="${1:-$DEFAULT_CHOICE}"

# Allow the user to optionally provide the data directory as an argument
DATA_DIRECTORY="${2:-$DEFAULT_DATA_DIRECTORY}"

# Define success and error log files
SUCCESS_LOG="${3:-success.log}"
ERROR_LOG="${4:-error.log}"

# Define prefix for output files
OUTPUT_PREFIX="${5:-_m6i.8xlarge}"

# Check if the directory exists
if [[ ! -d "$DATA_DIRECTORY" ]]; then
    echo "Error: Data directory '$DATA_DIRECTORY' does not exist."
    exit 1
fi

if [ "$CHOICE" = "ask" ]; then
    echo "Select the dataset size to benchmark:"
    echo "1) 1m (default)"
    echo "2) 10m"
    echo "3) 100m"
    echo "4) 1000m"
    echo "5) all"
    read -p "Enter the number corresponding to your choice: " CHOICE
fi

./install.sh

benchmark() {
    local size=$1
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    # Stateless: no load. The published .json.gz files are decompressed and queried in place.
    local jsonl_directory=~/data/bluesky_jsonl_${size}m
    ./prepare_data.sh "$DATA_DIRECTORY" "$jsonl_directory" "$size"
    ./total_size.sh "$jsonl_directory" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./count.sh "$jsonl_directory" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    #./query_results.sh "$jsonl_directory" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.query_results"
    ./benchmark.sh "$jsonl_directory" "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
    rm -rf "$jsonl_directory"
}

case $CHOICE in
    2)
        benchmark 10
        ;;
    3)
        benchmark 100
        ;;
    4)
        benchmark 1000
        ;;
    5)
        benchmark 1
        benchmark 10
        benchmark 100
        benchmark 1000
        ;;
    *)
        benchmark 1
        ;;
esac

./uninstall.sh
