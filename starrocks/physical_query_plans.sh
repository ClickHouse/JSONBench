#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DB_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"

# Load shared environment
source "$(dirname "$0")/env.sh"

QUERY_NUM=1

cat queries.sql | while read -r query; do

    # Print the query number
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Physical query plan for query Q$QUERY_NUM:"
    echo
    mysql -P "$DB_MYSQL_PORT" -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" -e "EXPLAIN $query"

    # Increment the query number
    QUERY_NUM=$((QUERY_NUM + 1))
done;
