#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY>"
    exit 1
fi
QUERY_NUM=1
cat queries.sql | while read -r query; do
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Result for query Q$QUERY_NUM:"
    echo
    ~/opteryx_venv/bin/python run_query.py "$1" "$query" 1 --print | grep -v '^Real time'
    QUERY_NUM=$((QUERY_NUM + 1))
done
