#!/bin/bash -e

cd "$(dirname "$0")"

function createTopic() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) topic name"
    exit 11
  fi

  set -e
  local TOPIC_NAME=$1

  echo "Creating topic '$TOPIC_NAME'"
  ../utils/kafka/create-topic-idempotently.sh "$TOPIC_NAME"
}

echo "Starting to create preconfigured topics ..."

while IFS= read -r TOPIC_NAME; do

  if [[ $TOPIC_NAME == "#"* ]]; then
    continue
  fi

  createTopic "$TOPIC_NAME"

done < "../../setup/kafka/topics.txt"

echo -e "DONE!\n\n"
