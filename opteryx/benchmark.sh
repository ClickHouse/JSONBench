#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> [RESULT_FILE]"
    exit 1
fi
DATA_DIRECTORY="$1"
RESULT_FILE="${2:-}"
echo "Running queries on: $DATA_DIRECTORY"
./run_queries.sh "$DATA_DIRECTORY" 2>&1 | tee query_log.txt
RESULT=$(cat query_log.txt | grep -oP 'Real time: \d+\.\d+ seconds' | sed -r -e 's/Real time: ([0-9]+\.[0-9]+) seconds/\1/' | \
awk '{ if (i % 3 == 0) { printf "[" }; printf $1; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }')
if [[ -n "$RESULT_FILE" ]]; then
    echo "$RESULT" > "$RESULT_FILE"
    echo "Result written to $RESULT_FILE"
else
    echo "$RESULT"
fi
