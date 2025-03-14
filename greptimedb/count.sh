#!/bin/bash

curl -s --fail http://localhost:4000/v1/sql \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "sql=select count(1) as cnt from jsontable"  \
    -d "format=json" \
    | grep -o "cnt\":[0-9]*" | sed 's/cnt\"://g'