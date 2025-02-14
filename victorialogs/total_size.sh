#!/bin/bash

curl -s --fail http://localhost:9428/select/logsql/query --data-urlencode "query=* | block_stats | sum(values_bytes) values_bytes, sum(dict_bytes) dict_bytes, sum(bloom_bytes) bloom_bytes | math values_bytes + dict_bytes + bloom_bytes total_bytes | keep total_bytes"
