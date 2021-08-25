#!/bin/bash

./specificSendTransactions.sh &

if docker exec -i nussknacker_kafka kafka-console-consumer.sh --topic alerts --bootstrap-server localhost:9092 | grep -q "Last packet"; then
  echo "Verification done"
  exit 0
fi
