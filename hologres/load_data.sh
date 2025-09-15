#!/bin/bash

# set -e

# Check if the required arguments are provided
if [[ $# -lt 6 ]]; then
    echo "Usage: $0 <directory> <database_name> <table_name> <max_files> <success_log> <error_log>"
    exit 1
fi

# Arguments
DIRECTORY="$1"
DIRECTORY=`realpath $DIRECTORY`
DB_NAME="$2"
TABLE_NAME="$3"
MAX_FILES="$4"
SUCCESS_LOG="$5"
ERROR_LOG="$6"
PSQL_CMD="$HOLOGRES_PSQL -d $DB_NAME"

FORCE_REPROCESS=0
SAVE_INTO_CACHE=1
CACHE_DIR=${DIRECTORY}/cleaned

# Validate that MAX_FILES is a number
if ! [[ "$MAX_FILES" =~ ^[0-9]+$ ]]; then
    echo "Error: <max_files> must be a positive integer."
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") START"

# Ensure the log files exist
touch "$SUCCESS_LOG" "$ERROR_LOG"
echo "SUCCESS_LOG $SUCCESS_LOG"
echo "ERROR_LOG $ERROR_LOG"

echo "---------------------------"
echo "FORCE_REPROCESS=$FORCE_REPROCESS"
echo "SAVE_INTO_CACHE=$SAVE_INTO_CACHE"
echo "CACHE_DIR=$CACHE_DIR"
echo "---------------------------"

# Create a temporary directory in /var/tmp and ensure it's accessible
TEMP_DIR=$(mktemp -d /var/tmp/cleaned_files.XXXXXX)
chmod 777 "$TEMP_DIR"  # Allow access for all users
trap "rm -rf $TEMP_DIR" EXIT  # Ensure cleanup on script exit

# Counter to track processed files
counter=0

# Loop through each .json.gz file in the directory
for file in $(ls "$DIRECTORY"/*.json.gz | sort); do
    if [[ -f "$file" ]]; then

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing $file ..."
        counter=$((counter + 1))

        filename=$(basename "$file" .gz)  # e.g., data.json
        cleaned_basename="${filename%.json}_cleaned.json"  # e.g., data_cleaned.json

        # 定义缓存文件路径（最终保存位置）
        cached_file=`realpath $CACHE_DIR/$cleaned_basename`

        # 如果缓存文件已经存在，就不再处理
        if [[ -f "$cached_file" && "$FORCE_REPROCESS" == 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cached file exists: $cached_file - skipping processing."
            cleaned_file="$cached_file"
        else
            # Uncompress the file into the temporary directory
            uncompressed_file="$TEMP_DIR/$filename"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] gunzip: $file ..."
            gunzip -c "$file" > "$uncompressed_file"

            # Check if uncompression was successful
            if [[ $? -ne 0 ]]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed to uncompress $file." | tee -a "$ERROR_LOG"
                continue
            fi
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] gunzip done: $uncompressed_file"
            # head -n 1 "$uncompressed_file"

            # Preprocess the file to remove null characters
            cleaned_file="$TEMP_DIR/$(basename "${uncompressed_file%.json}_cleaned.json")"
            cleaned_file_realpath=`realpath $cleaned_file`
            # sed 's/\\u0000//g' "$uncompressed_file" > "$cleaned_file"
            # 将跨越两行的 JSON 合并为一行（可以使导入成功率超过 99% ）
            sed 's/\\u0000//g' "$uncompressed_file" | awk 'NR == 1 { printf "%s", $0; next } /^{/ { printf "\n%s", $0; next } { printf "%s", $0 } END { print "" }' > "$cleaned_file"

            # head -n 1 "$cleaned_file"

            # Grant read permissions for the postgres user
            chmod 644 "$cleaned_file"

            if [[ "$SAVE_INTO_CACHE" != 0 ]]; then
                # 将 clean 后的文件保存到指定目录作为缓存
                mkdir -p "$CACHE_DIR"
                cp "$cleaned_file" "$cached_file"
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Saved cleaned file to cache: `realpath $cached_file`"
            fi
        fi

        # cp "$cleaned_file" /tmp/1.json
        echo `wc -l $cleaned_file`

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start importing $cleaned_file into Hologres." | tee -a "$SUCCESS_LOG"

        max_retries=3
        timeout_seconds=90
        attempt=1

        # Import the cleaned JSON file into Hologres

        until [ $attempt -gt $max_retries ]; do
            echo "($attempt) Try to copy data ..."
            timeout $timeout_seconds $PSQL_CMD -c "\COPY $TABLE_NAME FROM '$cleaned_file' WITH (format csv, quote e'\x01', delimiter e'\x02', escape e'\x01');"

            import_status=$?

            if [ $import_status -ne 124 ]; then
                break
            fi

            attempt=$((attempt + 1))
            sleep 1
        done

        # Check if the import was successful
        if [[ $import_status -eq 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully imported $cleaned_file into Hologres." | tee -a "$SUCCESS_LOG"
            # Delete both the uncompressed and cleaned files after successful processing
            rm -f "$uncompressed_file" "$cleaned_file_realpath"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed to import $cleaned_file. See errors above." | tee -a "$ERROR_LOG"
            # Keep the files for debugging purposes
        fi

        # Stop processing if the max number of files is reached
        if [[ $counter -ge $MAX_FILES ]]; then
            echo "Processed maximum number of files: $MAX_FILES"
            break
        fi
    else
        echo "No .json.gz files found in the directory."
    fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(basename "$0") DONE"
