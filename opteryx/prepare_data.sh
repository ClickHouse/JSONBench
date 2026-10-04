#!/bin/bash
# Opteryx queries NDJSON files in place: there is no load into a database. The only
# preparation is decompressing the first <NUM_FILES> published .json.gz files into
# <TARGET_DIRECTORY>, which is then queried as-is with READ_JSONL.
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <TARGET_DIRECTORY> <NUM_FILES>"
    exit 1
fi
DATA_DIRECTORY="$1"; TARGET_DIRECTORY="$2"; NUM_FILES="$3"
rm -rf "$TARGET_DIRECTORY"; mkdir -p "$TARGET_DIRECTORY"
ls "$DATA_DIRECTORY"/*.json.gz | sort | head -n "$NUM_FILES" | \
    xargs -P 16 -I{} bash -c 'pigz -dc "{}" > "'"$TARGET_DIRECTORY"'/$(basename "{}" .gz).jsonl"'
