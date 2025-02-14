#!/bin/bash

curl -s --fail http://localhost:9428/select/logsql/query --data-urlencode "query=* | block_stats | sum(bloom_bytes) index_bytes | keep index_bytes"
