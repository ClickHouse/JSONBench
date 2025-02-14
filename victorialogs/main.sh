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

benchmark() {
    local size=$1

    ./download_data.sh "$DATA_DIRECTORY" "$size"

    # install is needed here in order to drop the previously ingested data
    ./install.sh

    ./load_data.sh "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"

    # sleep for a while for settling down the data
    sleep 1

    ./total_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./data_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.data_size"
    ./index_size.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_size"
    ./count.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    #./query_results.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.query_results"
    ./run_queries.sh | tee "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
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
