#!/bin/bash

QUERY_NUM=1

cat queries.json5 | while read -r query; do

    # Print the query
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Result for query Q$QUERY_NUM:"
    echo

    curl -s --fail -X "POST" \
        "http://localhost:7280/api/v1/jsonbench/search" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$query" | jq ".aggregations"

    # Increment the query number
    QUERY_NUM=$((QUERY_NUM + 1))
done;
