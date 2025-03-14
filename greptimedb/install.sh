#!/bin/bash

RELEASE_VERSION=v0.13.0-nightly-20250315

# download greptimedb
wget -N "https://github.com/GreptimeTeam/greptimedb/releases/download/${RELEASE_VERSION}/greptime-linux-amd64-${RELEASE_VERSION}.tar.gz"
tar xzf greptime-linux-amd64-${RELEASE_VERSION}.tar.gz
mv greptime-linux-amd64-${RELEASE_VERSION}/greptime ./
rm -rf greptime-linux-amd64-${RELEASE_VERSION}
