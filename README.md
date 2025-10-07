# JSONBench: A Benchmark For Data Analytics on JSON

## Overview

This benchmark compares the native JSON support of the most popular analytical databases.

The [dataset](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#the-json-dataset---a-billion-bluesky-events) is a collection of files containing JSON objects delimited by newline (ndjson).
This was obtained using Jetstream to collect Bluesky events.
The dataset contains 1 billion Bluesky events and is currently hosted on a public S3 bucket.

We wrote a [detailed blog post](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql) about JSONBench, explaining how it works and showcasing benchmark results for five databases: ClickHouse, MongoDB, Elasticsearch, DuckDB, and PostgreSQL.

## Principles

The [main principles](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#benchmark-methodology) of this benchmark are:

### Reproducibility

It is easy to reproduce every test in a semi-automated way (although for some systems it may take from several hours to days).
The test setup is documented and uses inexpensive cloud VMs.
The test process is available in the form of a shell script, covering the installation of each database, loading of the data, running the workload, and collecting the result numbers.
The dataset is published and made available for download in multiple formats.

### Realism

[The dataset](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#the-json-dataset---a-billion-bluesky-events) represents real-world production data.
The realistic data distribution allows to account appropriately for compression, indices, codecs, custom data structures, etc., something that is not possible with most random data generators.
JSONBench tests various aspects of the hardware as well: some queries require high storage throughput, some queries benefit from a large number of CPU cores, and some benefit from single-core speed, some queries benefit from high main memory bandwidth.

### Fairness

Databases must be benchmarked using their default settings.
As an exception, it is okay to specify non-default settings if they are a prerequisite for running the benchmark (example: increasing the maximum JVM heap size).
Non-mandatory settings, especially settings related to workload tuning, are not allowed.

Some databases provide a native JSON data type that flattens nested JSON documents at insertion time to a single level, typically using `.` as separator between levels.
We consider this a grey zone.
On the one hand, flattening removes the possibility to restore the original documents.
On the other hand, flattening is in many practical situations acceptable.
The dashboard provides a toggle which allows to show or hide databases that use flattening.
In the scope of JSONBench, we generally discourage flattening.

Other forms of flattening, in particular flattening JSON into multiple non-JSON colums at insertion time, are disallowed.

It is allowed to index the data using clustered indexes (= specifying the table sort order) or non-clustered indexes (= additional data structures, e.g. B-trees).
We recognize that there are pros and cons of this approach.

Pros:
- The JSON documents in JSONBench expose a common and rather static structure. Many real-world use cases expose similar patterns. It is a widely used practice to create indexes based on the anticipated data structure.
- The original [blog post](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#some-json-paths-can-be-used-for-indexes-and-data-sorting) made use of indexes. Disallowing clustered indexes entirely would invalidate the original measurements.

Cons:
- There may be other real-world use cases where the JSON documents are highly dynamic (they share no common structure). In these cases, indexes are not useful.
- Many databases use indexes to prune the set of scanned data ranges or retrieve result rows directly (no scan). As a result, the benchmark indirectly also measures the effectiveness of such access path optimization techniques.
- Likewise, clustered indexes impact how well the data can be compressed. Again, this affects query runtimes indirectly.
- In some databases, clustered indexes must be build on top of flattened (e.g. concatenated and materialized) JSON documents. This technically contradicts the previous statement that flattening is discouraged.

It is not allowed to use cache query results (or generally intermediate results at the end of the query processing pipeline) between hot runs.

## Goals

The goal is to advance the possibilities of data analytics on semistructured data.
This benchmark is influenced by **[ClickBench](https://github.com/ClickHouse/ClickBench)** which was published in 2022 and has helped in improving performance, capabilities, and stability of many analytics databases.
We would like to see **JSONBench** having a similar impact on the community.

## Limitations

The benchmark focuses on data analytics queries over JSON documents rather than single-value retrieval or data modification operations.
The benchmark does not record data loading times.
While it was one of the initial goals, many systems require a finicky multi-step data preparation process, which makes them difficult to compare.

## Pre-requisites

To run the benchmark with 1 billion rows, it is important to provision a machine with sufficient resources and disk space.
The full compressed dataset takes 125 Gb of disk space, uncompressed it takes up to 425 Gb.

For reference, the initial benchmarks have been run on the following machines:
- Hardware: m6i.8xlarge AWS EC2 instance with 10Tb gp3 disks
- OS: Ubuntu 24.04

If you're interested in running the full benchmark, be aware that it will take several hours or days, depending on the database.

## Usage

Each folder contains the scripts required to run the benchmark on a database, by example [clickhouse](./clickhouse/) folder contains the scripts to run the benchmark on ClickHouse.

The full dataset contains 1 billion rows, but the benchmark runs for [different dataset sizes](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#the-json-dataset---a-billion-bluesky-events) (1 million, 10 million, 100 million and 1 billion rows) and [compression settings](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#the-json-dataset---a-billion-bluesky-events) in order to compare results at different scale.

### Download the data

Start by downloading the dataset using the script [`download_data.sh`](./download_data.sh).
When running the script, you will be prompted the dataset size you want to download.
If you just want to test it out, we recommend starting with the default 1m rows.
If you are interested in reproducing the results at scale, go with the full dataset (1 billion rows).

```
./download_data.sh

Select the dataset size to download:
1) 1m (default)
2) 10m
3) 100m
4) 1000m
Enter the number corresponding to your choice:
```

### Run the benchmark

Navigate to folder corresponding to the database you want to run the benchmark for.

The script `main.sh` is the script to run each benchmark.

Usage: `main.sh <DATA_DIRECTORY> <SUCCESS_LOG> <ERROR_LOG> <OUTPUT_PREFIX>`

- `<DATA_DIRECTORY>`: The directory where the dataset is stored. The default is `~/data/bluesky`.
- `<SUCCESS_LOG>`: The file to log successful operations. The default is `success.log`.
- `<ERROR_LOG>`: The file to log errors. The default is `error.log`.
- `<OUTPUT_PREFIX>`: The prefix for output files. The default is `_m6i.8xlarge`.

For example, for clickhouse:

```
cd clickhouse
./main.sh

Select the dataset size to benchmark:
1) 1m (default)
2) 10m
3) 100m
4) 1000m
5) all
Enter the number corresponding to your choice:
```

Enter the dataset size for which you want to run the benchmark, then hit enter.

The script installs the database system on the current machine and then prepares and runs the benchmark.

### Retrieve results

The results of the benchmark are stored within each folder in files prefixed with the $OUTPUT_PREFIX (Default is `_m6i.8xlarge`).

Below is a description of the files that might be generated as a result of the benchmark. Depending on the database, some files might not be generated because they are not relevant.

- `.total_size`: Contains the total size of the dataset.
- `.data_size`: Contains the data size of the dataset.
- `.index_size`: Contains the index size of the dataset.
- `.index_usage`: Contains the index usage statistics.
- `.physical_query_plans`: Contains the physical query plans.
- `.results_runtime`: Contains the runtime results of the benchmark.
- `.results_memory_usage`: Contains the memory usage results of the benchmark.

The last step of our benchmark is manual (PRs to automate this last step are welcome).
We manually retrieve the information from the outputted files into the final result JSON documents, which we add to the `results` subdirectory within the benchmark candidate's subdirectory.

For example, this is the [results](./clickhouse/results) directory for our ClickHouse benchmark results.

## Add a new database

We highly welcome additions of new entries in the benchmark! Please don't hesitate to contribute one.
You don't have to be affiliated with the database engine to contribute to the benchmark.

We welcome all types of databases, including open-source and closed-source, commercial and experimental, distributed or embedded, except one-off customized builds for the benchmark.

While the main benchmark uses a specific machine configuration for reproducibility, we will be interested in receiving results for cloud services and data lakes for reference comparisons.

- [x] [ClickHouse](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#clickhouse)
- [x] [Elasticsearch](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#elasticsearch)
- [x] [MongoDB](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#mongodb)
- [x] [DuckDB](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#duckdb)
- [x] [PostgreSQL](https://clickhouse.com/blog/json-bench-clickhouse-vs-mongodb-elasticsearch-duckdb-postgresql#postgresql)
- [x] VictoriaLogs
- [x] SingleStore
- [x] GreptimeDB
- [x] FerretDB
- [x] Apache Doris
- [ ] Quickwit
- [ ] Meilisearch
- [ ] Sneller
- [ ] Snowflake
- [ ] Manticore Search
- [ ] SurrealDB
- [ ] OpenText Vertica
- [ ] PartiQL
- [ ] FishStore
- [ ] Apache Drill
- [ ] GlareDB

## Similar projects

[The fastest command-line tools for querying large JSON datasets](https://colab.research.google.com/github/dcmoura/spyql/blob/master/notebooks/json_benchmark.ipynb)
