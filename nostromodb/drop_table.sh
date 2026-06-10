#!/bin/bash 

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <database_path>"
    exit 1
fi

# Arguments
DATABASE_PATH="$1"

echo "Dropping database: $DATABASE_PATH"

rm -rf "${DATABASE_PATH}"
