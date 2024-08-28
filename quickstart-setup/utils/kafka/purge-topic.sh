#!/bin/bash -e

if [ "$#" -ne 1 ]; then
  echo "ERROR: One parameter required: 1) topic name"
  exit 1
fi

if ! [ -v KAFKA_ADDRESS ] || [ -z "$KAFKA_ADDRESS" ]; then
  echo "ERROR: required variable KAFKA_ADDRESS not set or empty"
  exit 2
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1

kaf --brokers="$KAFKA_ADDRESS" topic delete "$TOPIC_NAME" > /dev/null
./create-topic-idempotently.sh
