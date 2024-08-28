#!/bin/bash -e

cd "$(dirname "$0")"

shopt -s nullglob

for FOLDER in /scenario-examples/*; do   
  if [ ! -f "$FOLDER/disabled" ]; then
    echo "Starting to send static and generated data for scenario from $FOLDER directory ..."

    ./http/send-http-static-requests.sh "$FOLDER"
    ./kafka/send-kafka-static-messages.sh "$FOLDER"
    ./http/continuously-send-http-generated-requests.sh "$FOLDER"
    ./kafka/continuously-send-kafka-generated-messages.sh "$FOLDER"

    echo -e "DONE!\n\n"
  else
    echo "Skipping sending static and generated data for scenario from $FOLDER directory."
  fi
done
