#!/bin/bash

set -e

cd "$(dirname $0)"

CONTAINER_NAME=nussknacker_kafka
TOPIC=$1
PARTITION_COUNT=$2

docker exec $CONTAINER_NAME kafka-topics.sh --delete --topic "$TOPIC" --bootstrap-server localhost:9092
docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --bootstrap-server localhost:9092 --partitions $PARTITION_COUNT --replication-factor 1
cat ./benchmarkTransactions.json | ./sendToKafka.sh transactions

