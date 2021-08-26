#!/bin/bash

# Before executing, make sure if DetectLargeTransactionsWithEndVerification is deployed

# Parameter is number of transactions to be performed
./sendTransactionsWithQuantity.sh "$1" &

if docker exec -it nussknacker_kafka sh -c "set -e; (kafka-console-consumer.sh --topic alerts --bootstrap-server localhost:9092 &) | grep -q 'Last request'"
then
  printf "\nLast request has been prepared\n"
else
  printf "\nLast request hasn't been found\n"
fi