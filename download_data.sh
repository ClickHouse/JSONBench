#!/bin/bash

echo "Select the dataset size to download:"
echo "1) 1m (default)"
echo "2) 10m"
echo "3) 100m"
echo "4) 1000m"
read -p "Enter the number corresponding to your choice: " choice

case $choice in
    2)
        # Download 10m dataset: files 0001 to 0010
        wget -N -P ~/data/bluesky -i <(seq -f "https://clickhouse-public-datasets.s3.amazonaws.com/bluesky/file_%04g.json.gz" 1 10)
        ;;
    3)
        # Download 100m dataset: files 0001 to 0100
        wget -N -P ~/data/bluesky -i <(seq -f "https://clickhouse-public-datasets.s3.amazonaws.com/bluesky/file_%04g.json.gz" 1 100)
        ;;
    4)
        # Download 1000m dataset: files 0001 to 1000
        wget -N -P ~/data/bluesky -i <(seq -f "https://clickhouse-public-datasets.s3.amazonaws.com/bluesky/file_%04g.json.gz" 1 1000)
        ;;
    *)
        # Download 1m dataset: single file
        wget -N -P ~/data/bluesky "https://clickhouse-public-datasets.s3.amazonaws.com/bluesky/file_0001.json.gz"
        ;;
esac