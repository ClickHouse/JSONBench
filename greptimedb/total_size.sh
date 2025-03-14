#!/bin/bash

curl -s --fail http://localhost:4000/v1/sql \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "sql=SELECT sum(r.disk_size) as total_size FROM information_schema.REGION_STATISTICS r LEFT JOIN information_schema.TABLES t on r.table_id = t.table_id WHERE t.table_name = 'jsontable'"  \
    -d "format=json"  \
    | grep -o "total_size\":[0-9]*" | sed 's/total_size\"://g'
