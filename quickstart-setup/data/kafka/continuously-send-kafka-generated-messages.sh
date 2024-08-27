#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function runMessageSending() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) topic name, 2) message generator script"
    exit 11
  fi

  set -e

  local TOPIC_NAME=$1
  local MSG_GENERATOR_SCRIPT=$2

  echo "Starting to send to '$TOPIC_NAME' messages generated by '$MSG_GENERATOR_SCRIPT' generator script"

  mkdir -p /var/log/continuously-send-to-topic
  nohup ../../utils/kafka/continuously-send-to-topic.sh "$TOPIC_NAME" "$MSG_GENERATOR_SCRIPT" > /var/log/continuously-send-to-topic/output.log 2>&1 &
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to send generated messages ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/data/kafka/generated"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.sh ]]; then
    echo "Unrecognized file $ITEM. Required file with extension '.sh' and content with bash script"
    exit 3
  fi

  TOPIC_NAME=$(basename "$ITEM" ".sh" | sed 's/.*/\u&/')

  runMessageSending "$TOPIC_NAME" "$ITEM"

done

echo -e "DONE!\n\n"
