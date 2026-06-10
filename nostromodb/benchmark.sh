#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DATA_DIR> <DATABASE_PATH> [RESULT_FILE]"
    exit 1
fi

# Arguments
DATA_DIR="$1"
DATABASE_PATH="$2"
RESULT_FILE="${3:-}"

# Print the database name
echo "Running queries on database: $DATABASE_PATH"

# Run queries and log the output
./run_queries.sh "$DATA_DIR" "$DATABASE_PATH" 2>&1 | tee query_log.txt

# Process the query log and prepare the result
RESULT=$(cat query_log.txt | grep -oP 'Real time: \d+\.\d+ seconds' | sed -r -e 's/Real time: ([0-9]+\.[0-9]+) seconds/\1/' | \
awk '{ if (i % 3 == 0) { printf "[" }; printf $1; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }')

# Output the result
if [[ -n "$RESULT_FILE" ]]; then
    echo "$RESULT" > "$RESULT_FILE"
    echo "Result written to $RESULT_FILE"
else
    echo "$RESULT"
fi
