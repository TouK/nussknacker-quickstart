#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 1 ]; then
  echo -e "${RED}ERROR: One parameter required: 1) topic name${RESET}\n"
  exit 1
fi

if ! [ -v KAFKA_ADDRESS ] || [ -z "$KAFKA_ADDRESS" ]; then
  echo -e "${RED}ERROR: required variable KAFKA_ADDRESS not set or empty${RESET}\n"
  exit 2
fi

TOPIC_NAME=$1

if ! kaf --brokers="$KAFKA_ADDRESS" topics ls | awk '{print $1}' | grep "^$TOPIC_NAME$" > /dev/null 2>&1; then
  kaf --brokers="$KAFKA_ADDRESS" topic create "$TOPIC_NAME" > /dev/null
fi