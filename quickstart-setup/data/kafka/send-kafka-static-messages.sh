#!/bin/bash -e

cd "$(dirname "$0")"

source ../../utils/lib.sh

if [ "$#" -ne 1 ]; then
    red_echo "ERROR: One parameter required: 1) scenario example folder path\n"
    exit 1
fi

function send_message() {
  if [ "$#" -ne 2 ]; then
    red_echo "ERROR: Two parameters required: 1) topic name, 2) message\n"
    exit 11
  fi

  set -e

  local TOPIC_NAME=$1
  local MSG=$2

  echo -n "Sending message $MSG to '$TOPIC_NAME'"
  ../../utils/kafka/send-to-topic.sh "$TOPIC_NAME" "$MSG"
  echo "OK"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to send preconfigured messages..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/data/kafka/static"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    red_echo "ERROR: Unrecognized file $ITEM. Required file with extension '.txt' and content with JSON messages\n"
    exit 3
  fi

  TOPIC_NAME=$(basename "$ITEM" ".sh" | sed 's/.*/\u&/')

  while IFS= read -r MSG; do
    if [[ $MSG == "#"* ]]; then
      continue
    fi

    send_message "$TOPIC_NAME" "$MSG"

  done < "$ITEM"
done

echo -e "Messages sent!\n"
