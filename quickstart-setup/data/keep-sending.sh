#!/bin/bash -e

cd "$(dirname "$0")"

for FOLDER in /scenario-examples/*/; do
    
  echo "Starting to send static and generated data for scenario from $FOLDER directory ..."

  ./http/send-http-static-requests.sh "$FOLDER"
  ./kafka/send-kafka-static-messages.sh "$FOLDER"
  ./http/continuously-send-http-generated-requests.sh "$FOLDER"
  ./kafka/continuously-send-kafka-generated-messages.sh "$FOLDER"

done
