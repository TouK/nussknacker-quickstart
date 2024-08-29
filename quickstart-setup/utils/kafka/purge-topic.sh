#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 1 ]; then
  red_echo "ERROR: One parameter required: 1) topic name\n"
  exit 1
fi

if ! [ -v KAFKA_ADDRESS ] || [ -z "$KAFKA_ADDRESS" ]; then
  red_echo "ERROR: required variable KAFKA_ADDRESS not set or empty\n"
  exit 2
fi

TOPIC_NAME=$1

kaf --brokers="$KAFKA_ADDRESS" topic delete "$TOPIC_NAME" > /dev/null
./create-topic-idempotently.sh
