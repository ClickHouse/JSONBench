#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"

TRIES=3

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

cat queries.sql | while read -r query; do

    # Hologres stores data in Pangu (distributed FS), which has no caching - therefore no need to clear OS or Pangu cache.

    # echo "Clearing file system cache..."
    # sync
    # echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    # echo "File system cache cleared."

    # Print the query
    echo "(TRIES: $TRIES) Running query: $query"

    # Execute the query multiple times
    for i in $(seq 1 $TRIES); do
        $HOLOGRES_PSQL -d "$DB_NAME" -t -c '\timing' -c "$query" | grep 'Time'
    done;
done;

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"
