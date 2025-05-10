#!/bin/bash

# If you change something in this file, please change also in starrocks/count.sh.

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"
TABLE_NAME="$2"

mysql -P 9030 -h 127.0.0.1 -u root $DB_NAME -e "SELECT count() FROM $TABLE_NAME;"
