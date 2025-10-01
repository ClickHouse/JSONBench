#!/bin/bash

echo "Stopping Quickwit"
pidof quickwit && kill $(pidof quickwit)

echo "Dropping all data"
rm -rf ./qwdata
