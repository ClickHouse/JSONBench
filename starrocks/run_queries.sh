#!/bin/bash

# If you change something in this file, please change also in doris/run_queries.sh.

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"

TRIES=3

cat queries.sql | while read -r query; do

    # Clear the Linux file system cache
    echo "Clearing file system cache..."
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo "File system cache cleared."

    # Print the query
    echo "Running query: $query"

    # Execute the query multiple times
    for i in $(seq 1 $TRIES); do
        RESP=$({ time -f '%e' \
                    mysql -N -s -h "$DB_HOST" -P "$DB_MYSQL_PORT" -u"$DB_USER" "$DB_NAME" \
                    -e "$query" >/dev/null; } 2>&1)
        echo "Response time: ${RESP} s"
    done;
done;
