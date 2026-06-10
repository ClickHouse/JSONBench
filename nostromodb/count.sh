#!/bin/bash 

# Check if the required arguments are provided
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <data_path> <database_path> <table_name>"
    exit 1
fi

# Arguments
DATA_PATH="$1"
DATABASE_PATH="$2"
TABLE_NAME="$3"

./run_statements.sh "$DATA_PATH" "$DATABASE_PATH" "select count(*) from $TABLE_NAME;"
