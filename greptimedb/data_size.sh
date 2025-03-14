#!/bin/bash

curl -s --fail http://localhost:4000/v1/sql \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "sql=SELECT sum(r.sst_size) as data_size FROM information_schema.REGION_STATISTICS r LEFT JOIN information_schema.TABLES t on r.table_id = t.table_id WHERE t.table_name = 'jsontable'"  \
    -d "format=json"  \
    | grep -o "data_size\":[0-9]*" | sed 's/data_size\"://g'
