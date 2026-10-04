#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY>"
    exit 1
fi
~/opteryx_venv/bin/python run_query.py "$1" "SELECT COUNT(*) FROM {TABLE}" 1 --print | tail -1
