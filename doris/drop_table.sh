#!/bin/bash

# If you change something in this file, please change also in starrocks/drop_table.sh.

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME>"
    exit 1
fi

DB_NAME="$1"
TABLE_NAME="$2"

echo "Dropping table: $DB_NAME.$TABLE_NAME"
mysql -P 9030 -h 127.0.0.1 -u root $DB_NAME -e "DROP TABLE IF EXISTS $TABLE_NAME"
