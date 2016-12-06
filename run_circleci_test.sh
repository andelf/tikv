#!/bin/bash

set -x

if test -z "$CIRCLE_NODE_TOTAL"; then
    echo must be run under CircleCI!
    exit 1
fi

# Job 0
if test $(( 0 % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX; then
    make format && git diff-index --quiet HEAD -- || \
            (echo please make format before creating a pr!; exit 1)
    cargo test --features "default" --bench benches -- --nocapture
    cargo test --features "default" -- --skip raftstore
fi

# Job 1
if test $(( 1 % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX; then
    cargo test --features "default" -- raftstore::test_multi
fi

# Job 2
if test $(( 2 % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX; then
    time cargo test --features "default" -- raftstore::test_single
    time cargo test --features "default" -- raftstore::test_tombstone
    time cargo test --features "default" -- raftstore::test_compact_log
    time cargo test --features "default" -- raftstore::test_snap
fi

# Job 3
if test $(( 3 % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX; then
    cargo test --features "default" -- \
          --skip raftstore::test_single \
          --skip raftstore::test_multi \
          --skip raftstore::test_tombstone \
          --skip raftstore::test_compact_log \
          --skip raftstore::test_snap \
          raftstore
fi
