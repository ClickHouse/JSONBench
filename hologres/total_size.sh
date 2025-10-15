#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"
TABLE_NAME="$2"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

$HOLOGRES_PSQL -d "$DB_NAME" -t -c "SELECT pg_relation_size('$TABLE_NAME')"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"
