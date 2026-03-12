#!/bin/bash

# The latest official release of Quickwit is too old, many unsupported tantivy quries.
# They publish edge build as Docker images to Docker Hub. We can extract the binary from that images.
#
# It will be replaced by the official release when it is updated.
#
# RELEASE_VERSION=v0.9.0
# wget -N "https://github.com/quickwit-oss/quickwit/releases/download/${RELEASE_VERSION}/quickwit-${RELEASE_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
# tar xzf quickwit-${RELEASE_VERSION}-x86_64-unknown-linux-gnu.tar.gz
# mv quickwit-${RELEASE_VERSION}/quickwit ./
# rm -rf quickwit-${RELEASE_VERSION} 
#
# Using prebuilt binary here for testing
PREBUILT_NAME=quickwit-f6cb417-x86_64-unknown-linux-gnu
wget -N "https://github-actions-assets.cometkim.dev/prebuilt/$PREBUILT_NAME"
mv "$PREBUILT_NAME" ./quickwit
chmod +x ./quickwit
