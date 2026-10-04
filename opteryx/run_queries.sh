#!/bin/bash
# Per query: drop the OS page cache, then run it TRIES times in one Opteryx process.
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY>"
    exit 1
fi
DATA_DIRECTORY="$1"
TRIES=3
cat queries.sql | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo "Running query: $query"
    ~/opteryx_venv/bin/python run_query.py "$DATA_DIRECTORY" "$query" "$TRIES"
done
