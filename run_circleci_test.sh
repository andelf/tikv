#!/bin/bash

case $CIRCLE_NODE_INDEX in
    0)
        make format && git diff-index --quiet HEAD -- || \
                (echo please make format before creating a pr!; exit 1)
        cargo test --features "default" --bench benches -- --nocapture
        cargo test --features "default" -- --skip coprocessor --skip raft --skip storage
        ;;
    1)
        cargo test --features "default" -- coprocessor
        ;;
    2)
        cargo test --features "default" -- raftstore
        ;;
    3)
        cargo test --features "default" -- storage
        ;;
esac
