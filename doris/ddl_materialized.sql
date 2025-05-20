CREATE TABLE bluesky (
    kind VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.kind')) NOT NULL,
    operation VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.commit.operation')) NULL,
    collection VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.commit.collection')) NULL,
    did VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data,'$.did')) NOT NULL,
    time DATETIME GENERATED ALWAYS AS (from_microsecond(get_json_bigint(data, '$.time_us'))) NOT NULL,
    `data` variant NOT NULL
)
DUPLICATE KEY (kind, operation, collection)
DISTRIBUTED BY HASH(collection, did) BUCKETS 32
PROPERTIES (
    "replication_num"="1"
);
