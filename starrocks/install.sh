#!/bin/bash

sudo snap install docker
sudo apt-get update
sudo apt-get install -y mysql-client

docker run -p 9030:9030 -p 8030:8030 -p 8040:8040 -itd --name starrocks starrocks/allin1-ubuntu


# Enable FlatJSON 
mysql -h 127.0.0.1 -P9030 -u root -e "SET GLOBAL cbo_prune_json_subfield = true";
mysql -h 127.0.0.1 -P9030 -u root -e "UPDATE information_schema.be_configs SET value = 'true' WHERE name = 'enable_json_flat'";