#!/bin/bash -e

cd "$(dirname "$0")"

TOPIC=${1-transactions}
TRANSACTION_COUNT=${2-1000}
CLIENT_COUNT=${3-10}
PARTITION_COUNT=${4-10}
TIME_SPREAD_MINUTES=${5-10}

function runInKafka() {
    ../../scripts/runInKafka.sh "$@"
}

#data is generated with timestamps in range [now, now + time_spread_minutes * 60000 millis]
#generating data for future instead of past is for benefit of watermarks if other real time process
#is running at the same time
echo "Preparing topics"

runInKafka kafka-topics --delete --topic alerts --bootstrap-server localhost:9092 --if-exists
runInKafka kafka-topics --create --topic alerts --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

runInKafka kafka-topics --delete --topic "$TOPIC" --bootstrap-server localhost:9092 --if-exists
runInKafka kafka-topics --create --topic "$TOPIC" --bootstrap-server localhost:9092 --partitions "$PARTITION_COUNT" --replication-factor 1

../../schemas/createSchemas.sh


echo "Topics prepared, running console producer..."
#we do this instead of copy, as we would have to have different scripts for docker and k8s
cat generateBenchmarkTransactions.sh | runInKafka bash -c "cat > /tmp/bench.sh; chmod +x /tmp/bench.sh"
#we want to generate events inside container, as piping large amount of data through kubectl exec is really costly (at least in k8s) 
runInKafka bash -c "/tmp/bench.sh $TRANSACTION_COUNT $CLIENT_COUNT $TIME_SPREAD_MINUTES | kafka-console-producer --topic $TOPIC --bootstrap-server localhost:9092"

#transaction_count + 1 is because of mark record at the end
sleep=10
waitLimit=120
echo "Messages sent, waiting for Kafka"
../../scripts/waitForKafka.sh "$TOPIC" "$((TRANSACTION_COUNT+1))" "$sleep" "$waitLimit"
