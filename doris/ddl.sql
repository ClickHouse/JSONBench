CREATE TABLE bluesky (
    kind VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.kind')) NOT NULL,
    operation VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.commit.operation')) NULL,
    collection VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data, '$.commit.collection')) NULL,
    did VARCHAR(100) GENERATED ALWAYS AS (get_json_string(data,'$.did')) NOT NULL,
    time DATETIME GENERATED ALWAYS AS (from_microsecond(get_json_bigint(data, '$.time_us'))) NOT NULL,
    `data` variant<'kind': string, 'commit.operation' : string, 'commit.collection' : string, 'did' : string, 'time_us' : bigint, properties("variant_max_subcolumns_count" = "1024")> NOT NULL,
    INDEX idx_kind(data) USING INVERTED PROPERTIES("field_pattern" = "kind"),
    INDEX idx_operation(data) USING INVERTED PROPERTIES("field_pattern" = "commit.operation"),
    INDEX idx_collection(data) USING INVERTED PROPERTIES("field_pattern" = "commit.collection"),
    INDEX idx_did(data) USING INVERTED PROPERTIES("field_pattern" = "did"),
    INDEX idx_time(data) USING INVERTED PROPERTIES("field_pattern" = "time_us"),
)
DUPLICATE KEY (kind, operation, collection, did)
DISTRIBUTED BY HASH(collection, did) BUCKETS 32
PROPERTIES ("replication_num"="1");
