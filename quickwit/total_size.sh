#!/bin/bash

du -b ${QW_DATA_DIR:-qwdata}/indexes/jsonbench | cut -f1
