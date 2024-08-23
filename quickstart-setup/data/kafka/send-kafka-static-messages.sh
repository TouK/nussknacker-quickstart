#!/bin/bash -e

cd "$(dirname "$0")"

function sendMessage() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) topic name, 2) message"
    exit 11
  fi

  set -e

  local TOPIC_NAME=$1
  local MSG=$2

  echo "Sending message $MSG to '$TOPIC_NAME'"
  ../../utils/kafka/send-to-topic.sh "$TOPIC_NAME" "$MSG"
  echo "Message sent!"
}

echo "Starting to send preconfigured messages ..."

while IFS= read -r TOPIC_NAME; do

  if [[ $TOPIC_NAME == "#"* ]]; then
    continue
  fi

  MESSAGES_FILE=$(find static-messages -iname "$TOPIC_NAME.txt" | head)

  if [[ -f "$MESSAGES_FILE" ]]; then
    while IFS= read -r MSG; do
      if [[ $MSG == "#"* ]]; then
        continue
      fi

      sendMessage "$TOPIC_NAME" "$MSG"
    done < "$MESSAGES_FILE"
  fi

done < "topics.txt"

echo -e "DONE!\n\n"
