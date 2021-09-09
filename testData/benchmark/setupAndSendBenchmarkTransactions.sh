#!/bin/bash

set -e

cd "$(dirname $0)"

CONTAINER_NAME=nussknacker_kafka
TOPIC=${1-transactions}
TRANSACTION_COUNT=${2-1000}
CLIENT_COUNT=${3-10}
PARTITION_COUNT=${4-10}
TIME_SPREAD_MINUTES=${5-10}
#data is generated with timestamps in range [now, now + time_spread_minutes * 60000 millis]
#generating data for future instead of past is for benefit of watermarks if other real time process
#is running at the same time

../../restartDocker.sh

#docker exec $CONTAINER_NAME kafka-topics.sh --delete --topic "$TOPIC" --zookeeper zookeeper:2181 --if-exists
#docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --zookeeper zookeeper:2181 --partitions "$PARTITION_COUNT" --replication-factor 1 --if-not-exists

./generateBenchmarkTransactions.sh "$TRANSACTION_COUNT" "$CLIENT_COUNT" "$TIME_SPREAD_MINUTES" | ../sendToKafka.sh "$TOPIC"

#transaction_count + 1 is because of mark record at the end
sleep=10
waitLimit=120
../waitForKafka.sh "$TOPIC" "$((TRANSACTION_COUNT+1))" "$sleep" "$waitLimit"
