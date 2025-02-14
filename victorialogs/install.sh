#!/bin/bash

RELEASE_VERSION=v1.10.1-victorialogs

# stop the existing victorialogs instance if any and drop its data
while true
do
    pidof victoria-logs-prod && kill `pidof victoria-logs-prod` || break
    sleep 1
done
rm -rf victoria-logs-data

# download victorialogs
wget -N https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/${RELEASE_VERSION}/victoria-logs-linux-amd64-${RELEASE_VERSION}.tar.gz
tar xzf victoria-logs-linux-amd64-${RELEASE_VERSION}.tar.gz
echo "Downloaded victorialogs."

# start victorialogs
./victoria-logs-prod -loggerOutput=stdout -retentionPeriod=20y -search.maxQueryDuration=5m > server.log &

while true
do
    curl -s --fail http://localhost:9428/select/logsql/query -d 'query=_time:2100-01-01Z' && break
    sleep 1
done

echo "Started victorialogs."
