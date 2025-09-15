#!/bin/bash

# set -e

# Check if the required arguments are provided
if [[ $# -lt 7 ]]; then
    echo "Usage: $0 <DB_NAME> <TABLE_NAME> <DDL_FILE> <DATA_DIRECTORY> <NUM_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

# Arguments
DB_NAME="$1"
TABLE_NAME="$2"
DDL_FILE="$3"
DATA_DIRECTORY="$4"
NUM_FILES="$5"
SUCCESS_LOG="$6"
ERROR_LOG="$7"

# Validate arguments
[[ ! -f "$DDL_FILE" ]] && { echo "Error: DDL file '$DDL_FILE' does not exist."; exit 1; }
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$NUM_FILES" =~ ^[0-9]+$ ]] && { echo "Error: NUM_FILES must be a positive integer."; exit 1; }

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

echo "Drop and create database"
$HOLOGRES_PSQL -c "DROP DATABASE IF EXISTS $DB_NAME" -c "CREATE DATABASE $DB_NAME"
echo "Disable result cache."
$HOLOGRES_PSQL -c "ALTER DATABASE $DB_NAME SET hg_experimental_enable_result_cache TO off;"

echo "Execute DDL"
$HOLOGRES_PSQL -d "$DB_NAME" -t < "$DDL_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Load data"
./load_data.sh "$DATA_DIRECTORY" "$DB_NAME" "$TABLE_NAME" "$NUM_FILES" "$SUCCESS_LOG" "$ERROR_LOG"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Vacuum analyze the table"
$HOLOGRES_PSQL -d "$DB_NAME" -c '\timing' -c "VACUUM $TABLE_NAME"
$HOLOGRES_PSQL -d "$DB_NAME" -c '\timing' -c "ANALYZE $TABLE_NAME"
$HOLOGRES_PSQL -d "$DB_NAME" -c '\timing' -c "select hologres.hg_full_compact_table('$TABLE_NAME')"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"
