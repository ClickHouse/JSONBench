#!/bin/bash

echo "Creating table bluesky..."
DDL_SQL=$(tr '\n' ' ' < "$DDL_FILE")
curl -i -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
    http://localhost:4000/v1/sql \
    -d "sql=$DDL_SQL" \
    -d "format=json"
