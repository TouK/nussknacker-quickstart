#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "One parameter required: 1) topic name"
    exit 1
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1

if ! kaf --brokers=kafka:9092 topics ls | awk '{print $1}' | grep "^$TOPIC_NAME$" > /dev/null 2>&1; then
  kaf --brokers=kafka:9092 topic create "$TOPIC_NAME" > /dev/null
fi