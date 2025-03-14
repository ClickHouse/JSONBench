#!/bin/bash

echo "Stopping GreptimeDB"
pidof greptime && kill `pidof greptime`

echo "Dropping all data"
rm -rf ./greptimedb_data
