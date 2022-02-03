#!/bin/bash

set -e

cd "$(dirname $0)"

TOPIC=${1-transactions}
TRANSACTION_COUNT=${2-1000}
CLIENT_COUNT=${3-10}
PARTITION_COUNT=${4-10}
TIME_SPREAD_MINUTES=${5-10}

function runInKafka() {
    runInKafka "$@"
}

#data is generated with timestamps in range [now, now + time_spread_minutes * 60000 millis]
#generating data for future instead of past is for benefit of watermarks if other real time process
#is running at the same time

runInKafka kafka-topics.sh --delete --topic alerts --bootstrap-server localhost:9092 --if-exists
runInKafka kafka-topics.sh --create --topic alerts --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

runInKafka kafka-topics.sh --delete --topic "$TOPIC" --bootstrap-server localhost:9092 --if-exists
runInKafka kafka-topics.sh --create --topic "$TOPIC" --bootstrap-server localhost:9092 --partitions "$PARTITION_COUNT" --replication-factor 1

#we do this instead of copy, as we would have to have different scripts for docker and k8s
cat generateBenchmarkTransactions.sh | runInKafka bash -c "cat > /tmp/bench.sh; chmod +x /tmp/bench.sh"
#we want to generate events inside container, as piping large amount of data through kubectl exec is really costly (at least in k8s) 
runInKafka bash -c "/tmp/bench.sh $TRANSACTION_COUNT $CLIENT_COUNT $TIME_SPREAD_MINUTES | kafka-console-producer.sh --topic $TOPIC --broker-list localhost:9092"

#transaction_count + 1 is because of mark record at the end
sleep=10
waitLimit=120
../../scripts/waitForKafka.sh "$TOPIC" "$((TRANSACTION_COUNT+1))" "$sleep" "$waitLimit"
