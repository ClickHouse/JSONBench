#!/bin/bash

QUERY_NUM=1

set -f
cat queries.logsql | while read -r query; do

    # Print the query
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Result for query Q$QUERY_NUM:"
    echo

    curl -s --fail http://localhost:9428/select/logsql/query --data-urlencode "query=$query"

    # Increment the query number
    QUERY_NUM=$((QUERY_NUM + 1))
done;
