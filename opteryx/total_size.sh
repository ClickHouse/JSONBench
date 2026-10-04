#!/bin/bash
# Bytes Opteryx queries: the decompressed NDJSON files themselves (there is no database).
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY>"
    exit 1
fi
du -sb "$1" | cut -f1
