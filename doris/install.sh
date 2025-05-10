#!/bin/bash

wget https://apache-doris-releases.oss-accelerate.aliyuncs.com/${DORIS_FULL_NAME}.tar.gz
mkdir ${DORIS_FULL_NAME}
tar -xvf ${DORIS_FULL_NAME}.tar.gz --strip-components 1 -C ${DORIS_FULL_NAME}

sudo apt-get update
sudo apt-get install -y mysql-client openjdk-17-jre-headless # somehow _EXACTLY_ v17 is needed
