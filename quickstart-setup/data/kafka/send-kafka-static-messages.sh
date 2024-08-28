#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "ERROR: One parameter required: 1) scenario example folder path"
    exit 1
fi

function sendMessage() {
  if [ "$#" -ne 2 ]; then
    echo "ERROR: Two parameters required: 1) topic name, 2) message"
    exit 11
  fi

  set -e

  local TOPIC_NAME=$1
  local MSG=$2

  echo "Sending message $MSG to '$TOPIC_NAME'"
  ../../utils/kafka/send-to-topic.sh "$TOPIC_NAME" "$MSG"
  echo "Message sent!"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to send preconfigured messages ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/data/kafka/static"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    echo "ERROR: Unrecognized file $ITEM. Required file with extension '.txt' and content with JSON messages"
    exit 3
  fi

  TOPIC_NAME=$(basename "$ITEM" ".sh" | sed 's/.*/\u&/')

  while IFS= read -r MSG; do
    if [[ $MSG == "#"* ]]; then
      continue
    fi

    sendMessage "$TOPIC_NAME" "$MSG"

  done < "$ITEM"
done

echo -e "DONE!\n\n"
