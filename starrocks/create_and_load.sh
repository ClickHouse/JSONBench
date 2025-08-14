#!/bin/bash

# If you change something in this file, please change also in doris/create_and_load.sh.

# Load shared environment
source "$(dirname "$0")/env.sh"

# Check if the required arguments are provided
if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME> <DATA_DIRECTORY> <NUM_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

# Arguments
DB_NAME="$1"
TABLE_NAME="$2"
DATA_DIRECTORY="$3"
NUM_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"
DDL_FILE="ddl.sql"

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$NUM_FILES" =~ ^[0-9]+$ ]] && { echo "Error: NUM_FILES must be a positive integer."; exit 1; }


echo "Create database"
mysql -P "$DB_MYSQL_PORT" -h "$DB_HOST" -u "$DB_USER" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"

echo "Execute DDL"
mysql -P "$DB_MYSQL_PORT" -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" < "$DDL_FILE"

echo "Load data"
./load_data.sh "$DATA_DIRECTORY" "$DB_NAME" "$TABLE_NAME" "$NUM_FILES" "$SUCCESS_LOG" "$ERROR_LOG"
