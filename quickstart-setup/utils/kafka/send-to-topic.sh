#!/bin/bash -e

if [ "$#" -ne 2 ]; then
  echo "ERROR: Two parameters required: 1) topic name, 2) message"
  exit 1
fi

if ! [ -v KAFKA_ADDRESS ] || [ -z "$KAFKA_ADDRESS" ]; then
  echo "ERROR: required variable KAFKA_ADDRESS not set or empty"
  exit 2
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1
MESSAGE=$2

if kaf --brokers="$KAFKA_ADDRESS" topics ls | awk '{print $1}' | grep "^$TOPIC_NAME$" > /dev/null 2>&1; then
  echo "$MESSAGE" | kaf --brokers="$KAFKA_ADDRESS" produce "$TOPIC_NAME" > /dev/null
else
  echo "ERROR: Topic name '$TOPIC_NAME' not found"
  exit 3
fi