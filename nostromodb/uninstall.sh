#!/bin/bash

# stop and remove all docker containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
sudo snap remove --purge docker
