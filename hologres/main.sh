#!/bin/bash

# set -e

if [ -z "${PG_USER+x}" ] || [ -z "$PG_USER" ]; then
    echo "Error: PG_USER is not set or empty. You can create a user in HoloWeb. (e.g. BASIC\$XXXX)" >&2
    exit 1
fi

if [ -z "${PG_PASSWORD+x}" ] || [ -z "$PG_PASSWORD" ]; then
    echo "Error: PG_PASSWORD is not set or empty." >&2
    exit 1
fi

if [ -z "${PG_HOSTNAME+x}" ] || [ -z "$PG_HOSTNAME" ]; then
    echo "Error: PG_HOSTNAME is not set or empty." >&2
    exit 1
fi

if [ -z "${PG_PORT+x}" ] || [ -z "$PG_PORT" ]; then
    echo "Error: PG_PORT is not set or empty." >&2
    exit 1
fi

./install.sh

PSQL_BIN="psql"

export HOLOGRES_PSQL="env PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD $PSQL_BIN -p $PG_PORT -h $PG_HOSTNAME -d postgres"

# echo $HOLOGRES_PSQL

export OUTPUT_PREFIX="_output_instance"

clean_variable() {
    unset HOLOGRES_PSQL
    unset OUTPUT_PREFIX
}

trap "clean_variable" EXIT SIGHUP SIGINT SIGTERM

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
# OUTPUT_PREFIX="${5:-_m6i.8xlarge}"
# OUTPUT_PREFIX="${5:-_output}"

# Check if the directory exists
if [[ ! -d "$DATA_DIRECTORY" ]]; then
    echo "Error: Data directory '$DATA_DIRECTORY' does not exist."
    exit 1
fi

echo "---------------------------"
echo "data will be load from: `realpath $DATA_DIRECTORY`"
echo "---------------------------"

if [ "$CHOICE" = "ask" ]; then
    echo "Select the dataset size to benchmark:"
    echo "1) 1m (default)"
    echo "2) 10m"
    echo "3) 100m"
    echo "4) 1000m"
    echo "5) all"
    read -p "Enter the number corresponding to your choice: " CHOICE
fi

benchmark() {
    local size=$1
    # Check DATA_DIRECTORY contains the required number of files to run the benchmark
    file_count=$(find "$DATA_DIRECTORY" -type f | wc -l)
    if (( file_count < size )); then
        echo "Error: Not enough files in '$DATA_DIRECTORY'. Required: $size, Found: $file_count."
        exit 1
    fi
    echo "---"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MAIN START"
    ./create_and_load.sh "bluesky_${size}m" bluesky "ddl.sql" "$DATA_DIRECTORY" "$size" "$SUCCESS_LOG" "$ERROR_LOG"
    ./total_size.sh "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.total_size"
    ./count.sh "bluesky_${size}m" bluesky | tee "${OUTPUT_PREFIX}_bluesky_${size}m.count"
    ./index_usage.sh "bluesky_${size}m" "EXPLAIN" | tee "${OUTPUT_PREFIX}_bluesky_${size}m.index_usage"
    ./benchmark.sh "bluesky_${size}m" "${OUTPUT_PREFIX}_bluesky_${size}m.results_runtime"
    ./drop_tables.sh "bluesky_${size}m"  # 不要随便 drop table ，便于调试

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MAIN DONE"
}

case $CHOICE in
    1)
        benchmark 1
        ;;
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

clean_variable

./uninstall.sh
