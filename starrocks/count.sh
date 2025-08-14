#!/bin/bash

# If you change something in this file, please change also in doris/count.sh.

# Check if the required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME>"
    exit 1
fi

# Arguments
DB_NAME="$1"
TABLE_NAME="$2"

# Load shared environment
source "$(dirname "$0")/env.sh"

mysql -P "$DB_MYSQL_PORT" -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" -e "SELECT count() FROM $TABLE_NAME;"
