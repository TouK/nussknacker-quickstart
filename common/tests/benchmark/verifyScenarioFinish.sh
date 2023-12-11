#!/bin/bash -e

cd "$(dirname "$0")"

TIMEOUT_MS=$((60 * 60 * 100))
COMMAND="kafka-console-consumer --bootstrap-server localhost:9092 --topic alerts --max-messages 1 --partition 0 --offset 0 --timeout-ms $TIMEOUT_MS"

if ../../scripts/runInKafka.sh "$COMMAND" | grep -q "Last request"; then
  echo "Last request has been processed"
  exit 0
else
  echo "Last request hasn't been found"
  exit 1
fi
