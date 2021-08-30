#!/bin/bash

set -e

cd "$(dirname $0)"

CONTAINER_NAME=nussknacker_kafka
TOPIC=${1-transactions}
TRANSACTION_COUNT=${2-1000}
CLIENT_COUNT=${3-10}
PARTITION_COUNT=${4-10}
TIME_SPREAD_MINUTES=${5-10}

calcOffsetSumInTopic() {
  docker exec nussknacker_kafka kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic $TOPIC |
  grep -e ':[[:digit:]]*:' | awk -F ":" '{sum += $3} END {print sum}'
}

docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --zookeeper zookeeper:2181 --partitions "$PARTITION_COUNT" --replication-factor 1 --if-not-exists

sumBefore=$(calcOffsetSumInTopic)
./generateBenchmarkTransactions.sh $TRANSACTION_COUNT $CLIENT_COUNT $TIME_SPREAD_MINUTES | ./sendToKafka.sh transactions
sumAfter=$(calcOffsetSumInTopic)

waitTime=0
sleep=10
waitLimit=120
offsetSum=$((sumAfter - sumBefore))

while [[ $waitTime -lt $waitLimit && ($offsetSum -lt $TRANSACTION_COUNT)]]
do
  sleep $sleep
  waitTime=$((waitTime+sleep))
  sumAfter=$(calcOffsetSumInTopic)
  offsetSum=$((sumAfter-sumBefore))
  if [[ offsetSum -lt $TRANSACTION_COUNT ]]
  then
    echo "All transactions have yet not been obtained by kafka within $waitTime sec, $offsetSum transactions processed so far."
  fi
done

if [[ offsetSum -lt $TRANSACTION_COUNT ]]
then
  echo "Transactions not obtained within time limit"
  exit 1
fi

echo "Number of records sent to topic: ${TOPIC}: "$((sumAfter - sumBefore))
