#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME> [RESULT_FILE]"
    exit 1
fi

# Arguments
DB_NAME="$1"
RESULT_FILE="${2:-}"

# Print the database name
echo "Running queries on database: $DB_NAME"

# Run queries and log the output
./run_queries.sh "$DB_NAME" 2>&1 | tee query_log.txt

# Process the query log and prepare the result
RESULT=$(cat query_log.txt | grep -oP 'Execution time: \d+ms' | sed -r 's/Execution time: ([0-9]+)/\1/' | \
awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }')

# Output the result
if [[ -n "$RESULT_FILE" ]]; then
    echo "$RESULT" > "$RESULT_FILE"
    echo "Result written to $RESULT_FILE"
else
    echo "$RESULT"
fi