#!/bin/bash

case $CIRCLE_NODE_INDEX in
    0)
        echo Test: format, misc
        make format && git diff-index --quiet HEAD -- || \
                (echo please make format before creating a pr!; exit 1)
        cargo test --features "default" --bench benches -- --nocapture
        cargo test --features "default" -- \
              --skip raftstore
        ;;
    1)
        cargo test --features "default" -- \
              raftstore::test_multi
        ;;
    2)
        cargo test --features "default" -- \
              raftstore::store
        ;;
    3)
        cargo test --features "default" -- \
              raftstore \
              --skip raftstore::test_multi \
              --skip raftstore::store
        ;;
esac
