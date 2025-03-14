#!/bin/bash

curl -s --fail http://localhost:4000/v1/sql \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "sql=SELECT sum(r.index_size) as index_size FROM information_schema.REGION_STATISTICS r LEFT JOIN information_schema.TABLES t on r.table_id = t.table_id WHERE t.table_name = 'jsontable'"  \
    -d "format=json"  \
    | grep -o "index_size\":[0-9]*" | sed 's/index_size\"://g'
