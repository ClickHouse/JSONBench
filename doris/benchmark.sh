#!/bin/bash

# If you change something in this file, please change also in starrocks/benchmark.sh.

# Check if the required arguments are provided
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <DB_NAME> <RESULT_FILE_RUNTIMES> <QUERIES_FILE>"
    exit 1
fi

# Arguments
DB_NAME="$1"
RESULT_FILE_RUNTIMES="$2"
QUERIES_FILE="$3"

# Construct the query log file name using $DB_NAME
QUERY_LOG_FILE="query_log.txt"

# Print the database name
echo "Running queries on database: $DB_NAME"

# Run queries and log the output
./run_queries.sh "$DB_NAME" "$QUERIES_FILE"  2>&1 | tee query_log.txt

# Process the query log and prepare the result
RESULT=$(cat query_log.txt | grep -oP 'Response time: \d+\.\d+ s' | sed -r -e 's/Response time: ([0-9]+\.[0-9]+) s/\1/' | \
awk '{ if (i % 3 == 0) { printf "[" }; printf $1; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }')

# Output the result
if [[ -n "$RESULT_FILE_RUNTIMES" ]]; then
    echo "$RESULT" > "$RESULT_FILE_RUNTIMES"
    echo "Result written to $RESULT_FILE_RUNTIMES"
else
    echo "$RESULT"
fi
