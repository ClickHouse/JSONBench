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

    ./start.sh
    ./load_data.sh "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    sleep 1 
    ./total_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./data_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.data_size"
    ./index_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_size"
    ./count.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    ./run_queries.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
    ./drop_tables.sh 
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
