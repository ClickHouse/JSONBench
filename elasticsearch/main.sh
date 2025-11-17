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
    ./start.sh
    local size=$1
    local template=$2
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    ./create_and_load.sh "bluesky-${template}-${size}m" "index_template_${template}" "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh "bluesky-${template}-${size}m" | tee "${OUTPUT_PREFIX}_bluesky-${template}-${size}m.data_size"
    ./count.sh "bluesky-${template}-${size}m" | tee "${OUTPUT_PREFIX}_bluesky-${template}-${size}m.count"
    #./query_results.sh "bluesky-${template}-${size}m" | tee "${OUTPUT_PREFIX}_bluesky-${template}-${size}m.query_results"
    ./benchmark.sh "bluesky-${template}-${size}m" "${OUTPUT_PREFIX}_bluesky-${template}-${size}m.results_runtime"
    ./drop_tables.sh
}

case $CHOICE in
    2)
        benchmark 10 no_source
        benchmark 10 source
        ;;
    3)
        benchmark 100 no_source
        benchmark 100 source
        ;;
    4)
        benchmark 1000 no_source
        benchmark 1000 source
        ;;
    5)
        benchmark 1 no_source
        benchmark 1 source
        benchmark 10 no_source
        benchmark 10 source
        benchmark 100 no_source
        benchmark 100 source
        benchmark 1000 no_source
        benchmark 1000 source
        ;;
    *)
        benchmark 1 no_source
        benchmark 1 source
        ;;
esac

./uninstall
