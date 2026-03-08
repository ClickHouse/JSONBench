#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"
EXPLAIN_CMD="$2"

QUERY_NUM=1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

cat queries.sql | while read -r query; do

    # Print the query number
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Index usage for query Q$QUERY_NUM:"
    echo

    $HOLOGRES_PSQL -d "$DB_NAME" -t -c "$EXPLAIN_CMD $query"

    # Increment the query number
    QUERY_NUM=$((QUERY_NUM + 1))

done;

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"