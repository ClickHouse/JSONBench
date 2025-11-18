#!/bin/bash

curl -s --fail http://localhost:7280/api/v1/indexes/jsonbench/describe \
    | jq ".size_published_splits"
