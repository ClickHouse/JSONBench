#!/bin/bash

# If you change something in this file, please change also in doris/drop_table.sh.

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME>"
    exit 1
fi

DB_NAME="$1"
TABLE_NAME="$2"

echo "Dropping table: $DB_NAME.$TABLE_NAME"
# Load shared environment
source "$(dirname "$0")/env.sh"

mysql -P "$DB_MYSQL_PORT" -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" -e "DROP TABLE IF EXISTS $TABLE_NAME"
