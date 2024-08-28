#!/bin/bash -e

cd "$(dirname "$0")"

source ../../utils/lib.sh

if [ "$#" -ne 1 ]; then
    echo -e "${RED}ERROR: One parameter required: 1) scenario example folder path${RESET}\n"
    exit 1
fi

function createTopic() {
  if [ "$#" -ne 1 ]; then
    echo -e "${RED}ERROR: One parameter required: 1) topic name${RESET}\n"
    exit 11
  fi

  set -e
  local TOPIC_NAME=$1

  echo -n "Creating topic '$TOPIC_NAME'... "
  ../../utils/kafka/create-topic-idempotently.sh "$TOPIC_NAME"
  echo "OK"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to create preconfigured topics..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/setup/kafka"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    echo -e "${RED}ERROR: Unrecognized file $ITEM. Required file with extension '.txt' and content with topic names${RESET}\n"
    exit 2
  fi

  while IFS= read -r TOPIC_NAME; do

    if [[ $TOPIC_NAME == "#"* ]]; then
      continue
    fi

    createTopic "$TOPIC_NAME"

  done < "$ITEM"
done

echo -e "Topics created!\n"
