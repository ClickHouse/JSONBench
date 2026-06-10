#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DATA_DIR> <DATABASE_PATH>"
    exit 1
fi

# Arguments
DATA_DIR="$1"
DATABASE_PATH="$2"

QUERY_NUM=1

cat queries.sql | while read -r query; do
    # Print the query number
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Physical query plan for query Q$QUERY_NUM:"
    echo

    ./run_statements.sh "$DATA_DIR" "$DATABASE_PATH" "EXPLAIN $query"

    # Increment the query number
    QUERY_NUM=$((QUERY_NUM + 1))
done;
