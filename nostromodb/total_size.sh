#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <database_name>"
    exit 1
fi

# Arguments
DATABASE_NAME="$1"

du "$DATABASE_NAME" | awk '{print $1 * 1024}'
