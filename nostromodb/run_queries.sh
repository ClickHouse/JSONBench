#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIR> <DB_PATH>"
    exit 1
fi

# Arguments
DATA_DIR="$1"
DB_PATH="$2"

TRIES=3

cat queries.sql | while read -r query; do
    # Clear filesystem cache between queries.
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

    echo "Running query: $query"
    for i in $(seq 1 $TRIES); do
        # Run query with profiling enabled and extract the real time.
        REAL_TIME=$(./run_statements.sh "$DATA_DIR" "$DB_PATH" "profile $query" | grep -i "optimization took" | awk '{print substr($3, 1, length($3)-3)}')
        echo "Real time: $REAL_TIME seconds"
    done
done
