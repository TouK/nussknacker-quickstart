#!/bin/bash -e

cd "$(dirname "$0")"

COMMAND="kafka-console-consumer --bootstrap-server localhost:9092 --topic alerts --from-beginning --max-messages 1"
TIMEOUT=360s

if timeout $TIMEOUT ../../scripts/runInKafka.sh $COMMAND | grep -q "Last request"; then
  echo "Last request has been processed"
  exit 0
else
  echo "Last request hasn't been found"
  exit 1
fi
