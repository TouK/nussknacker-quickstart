#!/bin/bash

# Before executing, make sure if DetectLargeTransactionsWithAlertOnSpecific is deployed

./specificSendTransactions.sh "$1" &

if (docker exec -i nussknacker_kafka kafka-console-consumer.sh --topic alerts --bootstrap-server localhost:9092 &) | grep -q "Last request"; then
  printf "\nLast request had been prepared\n"
  exit 0
fi