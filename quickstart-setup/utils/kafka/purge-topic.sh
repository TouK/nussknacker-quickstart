#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: One parameter required: 1) topic name"
    exit 1
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1

kaf --brokers=kafka:9092 topic delete "$TOPIC_NAME" > /dev/null
./create-topic-idempotently.sh
