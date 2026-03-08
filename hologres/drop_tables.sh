#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

# echo "Dropping database"
$HOLOGRES_PSQL -c "DROP DATABASE $DB_NAME"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"
