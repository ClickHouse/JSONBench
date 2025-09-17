CREATE TABLE bluesky (
    data JSONB NOT NULL
);

ALTER TABLE bluesky ALTER COLUMN data SET (enable_columnar_type = ON);
CALL set_table_property('bluesky', 'dictionary_encoding_columns', 'data:auto');
CALL set_table_property('bluesky', 'bitmap_columns', 'data:auto');
