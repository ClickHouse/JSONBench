#!/bin/bash

curl -s --fail http://localhost:9428/select/logsql/query --data-urlencode "query=* | count() rows"
