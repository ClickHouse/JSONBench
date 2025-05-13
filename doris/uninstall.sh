#!/bin/bash

sudo apt-get remove -y mysql-client openjdk-17-jre-headless

rm -rf ${DORIS_FULL_NAME}
