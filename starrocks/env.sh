#!/bin/bash

# Shared configuration for StarRocks connection
# MySQL-compatible query endpoint
export DB_HOST="127.0.0.1"
export DB_MYSQL_PORT="9030"
export DB_USER="root"

# HTTP endpoint for Stream Load
export DB_HTTP_PORT="8030"