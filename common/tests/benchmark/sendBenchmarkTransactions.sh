#!/bin/bash

set -e

cd "$(dirname $0)"

TOPIC=${1-transactions}
TRANSACTION_COUNT=${2-1000}
CLIENT_COUNT=${3-10}
PARTITION_COUNT=${4-10}
TIME_SPREAD_MINUTES=${5-10}
#data is generated with timestamps in range [now, now + time_spread_minutes * 60000 millis]
#generating data for future instead of past is for benefit of watermarks if other real time process
#is running at the same time

../scripts/runInKafka.sh  kafka-topics.sh --delete --topic alerts --bootstrap-server localhost:9092 --if-exists
../scripts/runInKafka.sh  kafka-topics.sh --create --topic alerts --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

../scripts/runInKafka.sh kafka-topics.sh --delete --topic "$TOPIC" --bootstrap-server localhost:9092 --if-exists
../scripts/runInKafka.sh kafka-topics.sh --create --topic "$TOPIC" --bootstrap-server localhost:9092 --partitions "$PARTITION_COUNT" --replication-factor 1

./generateBenchmarkTransactions.sh "$TRANSACTION_COUNT" "$CLIENT_COUNT" "$TIME_SPREAD_MINUTES" | ../scripts/sendToKafka.sh "$TOPIC"

#transaction_count + 1 is because of mark record at the end
sleep=10
waitLimit=120
../scripts/waitForKafka.sh "$TOPIC" "$((TRANSACTION_COUNT+1))" "$sleep" "$waitLimit"
