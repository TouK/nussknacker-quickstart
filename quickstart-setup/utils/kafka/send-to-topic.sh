#!/bin/bash -e

if [ "$#" -ne 2 ]; then
    echo "Two parameters required: 1) topic name, 2) message"
    exit 1
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1
MESSAGE=$2

if kaf --brokers=kafka:9092 topics ls | awk '{print $1}' | grep "^$TOPIC_NAME$" > /dev/null 2>&1; then
  echo "$MESSAGE" | kaf --brokers=kafka:9092 produce "$TOPIC_NAME" > /dev/null
else
  echo "Topic name '$TOPIC_NAME' not found"
  exit 2
fi