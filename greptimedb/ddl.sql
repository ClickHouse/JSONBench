CREATE TABLE bluesky (
    "data" JSON (
        format = "partial", 
        fields = Struct<kind String, "commit.operation" String, "commit.collection" String, did String, time_us Bigint>
    ),
    time_us TimestampMicrosecond TIME INDEX
)
