#!/bin/bash

sudo snap install docker
sudo apt-get update
sudo apt-get install -y mysql-client

docker run -p 9030:9030 -p 8030:8030 -p 8040:8040 -itd --name starrocks starrocks/allin1-ubuntu:4.0.1

echo "Starting StarRocks container..."
sleep 5

# Monitor logs until "Enjoy" appears
echo "Monitoring container logs for 'Enjoy' message..."
timeout 300 docker logs -f starrocks | while read line; do
    echo "$line"
    if echo "$line" | grep -q "Enjoy"; then
        echo "Found 'Enjoy' message! Container is ready."
        # Kill the docker logs process
        pkill -f "docker logs -f starrocks"
        break
    fi
done

echo "StarRocks started successfully."
