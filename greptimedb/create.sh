#!/bin/bash

echo "Creating pipeline \"jsonbench\" ..."
curl -i -X POST 'http://localhost:4000/v1/events/pipelines/jsonbench' -F 'file=@pipeline.yaml'

echo "Creating table \"bluesky\" ..."
DDL_SQL=$(tr '\n' ' ' < ddl.sql)
curl -i -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
    http://localhost:4000/v1/sql \
    -d "sql=$DDL_SQL" \
    -d "format=json"
