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
OUTPUT_PREFIX="${4:-_m6i.8xlarge}"

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
    local suffix=$2
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    ./start.sh
    ./create_and_load.sh "bluesky_${size}m_${suffix}" bluesky "ddl_${suffix}.sql" "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh "bluesky_${size}m_${suffix}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.total_size"
    ./data_size.sh "bluesky_${size}m_${suffix}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.data_size"
    ./index_size.sh "bluesky_${size}m_${suffix}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.index_size"
    ./count.sh "bluesky_${size}m_${suffix}" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.count"
    #./query_results.sh "bluesky_${size}m_${suffix}" | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.query_results"
    ./index_usage.sh "bluesky_${size}m_${suffix}" | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.index_usage"
    ./physical_query_plans.sh "bluesky_${size}m_${suffix}" | tee "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.physical_query_plans"
    ./benchmark.sh "bluesky_${size}m_${suffix}" "${OUTPUT_PREFIX}_bluesky_${size}m_${suffix}.results_runtime"
    ./drop_table.sh # also stops ClickHouse
}

case $CHOICE in
    2)
        benchmark 10 lz4
        benchmark 10 zstd
        ;;
    3)
        benchmark 100 lz4
        benchmark 100 zstd
        ;;
    4)
        benchmark 1000 lz4
        benchmark 1000 zstd
        ;;
    5)
        benchmark 1 lz4
        benchmark 1 zstd
        benchmark 10 lz4
        benchmark 10 zstd
        benchmark 100 lz4
        benchmark 100 zstd
        benchmark 1000 lz4
        benchmark 1000 zstd
        ;;
    *)
        benchmark 1 lz4
        benchmark 1 zstd
        ;;
esac
