#!/bin/bash

TRIES=3

cat queries.json5 | while read -r query; do

    # Clear the Linux file system cache
    echo "Clearing file system cache..."
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo "File system cache cleared."

    # Print the query
    echo "Running query: $query"

    echo -n "["
    # Execute the query multiple times
    for i in $(seq 1 $TRIES); do
        response=$(curl -s --fail -X "POST" \
            "http://localhost:7280/api/v1/jsonbench/search" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$query")
        exit_code=$?
        if [[ "$exit_code" == "0" ]]; then
            elapsed_micros=$(echo "$response" | jq -r '.elapsed_time_micros // empty')
            if [[ -n "$elapsed_micros" ]]; then
                RES=$(awk "BEGIN {print $elapsed_micros / 1000000}" | tr ',' '.')
                echo -n "${RES}"
            else
                echo -n "null"
            fi
        else
            echo -n "null"
        fi
        [[ "$i" != $TRIES ]] && echo -n ", "
    done;
    echo "]"
done;
