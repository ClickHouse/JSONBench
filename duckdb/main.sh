#!/bin/bash

# Default data directory
DEFAULT_DATA_DIRECTORY=~/data/bluesky

# Allow the user to optionally provide the data directory as an argument
DATA_DIRECTORY="${1:-$DEFAULT_DATA_DIRECTORY}"

# Define success and error log files
SUCCESS_LOG="${2:-success.log}"
ERROR_LOG="${3:-error.log}"

# Define prefix for output files
OUTPUT_PREFIX="${4:-_m6i.8xlarge}"

# Check if the directory exists
if [[ ! -d "$DATA_DIRECTORY" ]]; then
    echo "Error: Data directory '$DATA_DIRECTORY' does not exist."
    exit 1
fi

echo "Select the dataset size to benchmark:"
echo "1) 1m (default)"
echo "2) 10m"
echo "3) 100m"
echo "4) 1000m"
echo "5) all"
read -p "Enter the number corresponding to your choice: " choice

./install.sh

benchmark() {
    local size=$1
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    ./create_and_load.sh "db.duckdb_${size}" bluesky ddl.sql "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh "db.duckdb_${size}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.data_size"
    ./count.sh "db.duckdb_${size}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    #./query_results.sh "db.duckdb_${size}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.query_results"
    ./physical_query_plans.sh "db.duckdb_${size}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.physical_query_plans"
    ./benchmark.sh "db.duckdb_${size}" "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
    ./drop_table.sh "db.duckdb_${size}"
}

case $choice in
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
