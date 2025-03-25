#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# NOTE: Provide license key and PASSWORD here
LICENSE_KEY=""
ROOT_PASSWORD=""
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

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

./install.sh "${LICENSE_KEY}" "${ROOT_PASSWORD}"

benchmark() {
    local size=$1
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    ./create_and_load.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky "ddl.sql" "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./data_size.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.data_size"
    ./index_size.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_size"
    ./count.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    ./query_results.sh "${ROOT_PASSWORD}" "bluesky_${size}m" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.query_results"
    # ./physical_query_plans.sh "${ROOT_PASSWORD}" "bluesky_${size}m" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.physical_query_plans"
    ./benchmark.sh "${ROOT_PASSWORD}" "bluesky_${size}m" "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime" "${OUTPUT_PREFIX}_bluesky_${size}m.results_memory_usage"
    ./drop_table.sh "${ROOT_PASSWORD}" "bluesky_${size}m" bluesky
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
