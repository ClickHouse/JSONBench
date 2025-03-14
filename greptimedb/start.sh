#!/bin/bash

# Do we run already?
pidof greptime >/dev/null && exit 1

BASEDIR=greptimedb_data

echo "Starting Greptimedb"
export GREPTIMEDB_STANDALONE__WAL__DIR="${BASEDIR}/wal"
export GREPTIMEDB_STANDALONE__STORAGE__DATA_HOME="${BASEDIR}"
export GREPTIMEDB_STANDALONE__LOGGING__DIR="${BASEDIR}/logs"
export GREPTIMEDB_STANDALONE__LOGGING__APPEND_STDOUT=false
export GREPTIMEDB_STANDALONE__HTTP__BODY_LIMIT=1GB
export GREPTIMEDB_STANDALONE__HTTP__TIMEOUT=500s
./greptime standalone start &

while true
do
    curl -s --fail http://localhost:4000/health && break
    sleep 1
done
echo "Started greptimedb."

# init pipeline
curl -s -XPOST 'http://localhost:4000/v1/events/pipelines/jsonbench' -F 'file=@pipeline.yaml'
echo "Pipeline initialized."
