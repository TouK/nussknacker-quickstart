#!/bin/bash -ex

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function createTopic() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) topic name"
    exit 11
  fi

  set -e
  local TOPIC_NAME=$1

  echo "Creating topic '$TOPIC_NAME'"
  ../../utils/kafka/create-topic-idempotently.sh "$TOPIC_NAME"
}

SCENARIO_EXAMPLE_DIR_PATH=$1

echo "Starting to create preconfigured topics ..."

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH"/kafka/*; do
  if [ ! -f "$ITEM" ]; then
    echo "Unrecognized file $ITEM. Required file with extension '.txt' and content with topic names"
    exit 2
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    echo "Unrecognized file $ITEM. Required file with extension '.txt' and content with topic names"
    exit 3
  fi

  while IFS= read -r TOPIC_NAME; do

    if [[ $TOPIC_NAME == "#"* ]]; then
      continue
    fi

    createTopic "$TOPIC_NAME"

  done < "$ITEM"
done

echo -e "DONE!\n\n"
