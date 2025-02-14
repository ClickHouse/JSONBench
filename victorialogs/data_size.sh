#!/bin/bash

curl -s --fail http://localhost:9428/select/logsql/query --data-urlencode "query=* | block_stats | sum(values_bytes) values_bytes, sum(dict_bytes) dict_bytes | math values_bytes + dict_bytes data_bytes | keep data_bytes"
