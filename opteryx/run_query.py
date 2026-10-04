"""Run one JSONBench query in one Opteryx process: try 1 is cold (the caller drops the OS page
cache first), later tries are hot. Prints 'Real time: <s> seconds' per try (query execution
only, not interpreter start-up), and the result rows with --print.

Malformed records are skipped (ignore_errors): the Bluesky dump has a few records split by a
raw newline or holding a raw control character, which are invalid JSON."""
import sys
import time

import opteryx

data_dir, query, tries = sys.argv[1], sys.argv[2], int(sys.argv[3])
show = len(sys.argv) > 4 and sys.argv[4] == "--print"
sql = query.replace("{TABLE}", f"READ_JSONL('{data_dir}/*.jsonl', ignore_errors => true)").rstrip().rstrip(";")
for _ in range(tries):
    session = opteryx.session()
    start = time.monotonic_ns()
    rows = []
    for morsel in session.execute_to_morsels(sql):
        rows.extend(zip(*[morsel.column(c) for c in morsel.column_names]))
    print(f"Real time: {(time.monotonic_ns() - start) / 1e9:.3f} seconds", flush=True)
if show:
    for row in rows:
        print("\t".join(map(str, row)))
