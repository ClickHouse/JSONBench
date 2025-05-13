#!/bin/bash

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
sudo sysctl -w vm.max_map_count=2000000
sudo sh -c ulimit -n 655350

${DORIS_FULL_NAME}/be/bin/start_be.sh --daemon
${DORIS_FULL_NAME}/fe/bin/start_fe.sh --daemon

echo "Sleep 30 sec to wait doris start"
sleep 30s

mysql -P 9030 -h 127.0.0.1 -u root -e "ALTER SYSTEM ADD BACKEND \"127.0.0.1:9050\";"

echo "Sleep 10 sec to wait frontend are connected to backend"
sleep 10s
