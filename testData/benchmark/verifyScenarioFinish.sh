#!/bin/bash

set -e

cd "$(dirname $0)"

if docker exec nussknacker_kafka kafka-console-consumer.sh \
              --bootstrap-server localhost:9092 --topic alerts --from-beginning --max-messages 1 | \
              grep -q "Last request"
then
  echo "Last request has been processed"
  exit 0
else1
  echo "Last request hasn't been found"
  exit 1
fi
