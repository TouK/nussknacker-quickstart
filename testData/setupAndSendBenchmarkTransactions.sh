#!/bin/bash

set -e

cd "$(dirname $0)"

CONTAINER_NAME=nussknacker_kafka
TOPIC=$1
PARTITION_COUNT=$2
TRANSACTION_COUNT=$((CLIENTID_COUNT * TRANSACTIONS_PER_CLIENT))

calcOffsetSumInTopic() {
  docker exec nussknacker_kafka kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic $TOPIC |
  grep -e ':[[:digit:]]*:' | awk -F ":" '{sum += $3} END {print sum}'
}

CLIENTID_COUNT=100
TRANSACTIONS_PER_CLIENT=10
TIME_DEVIATION_PARAMETER=10
./generateBenchmarkTransactions.sh $CLIENTID_COUNT $TRANSACTIONS_PER_CLIENT $TIME_DEVIATION_PARAMETER

docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --zookeeper zookeeper:2181 --partitions "$PARTITION_COUNT" --replication-factor 1 --if-not-exists

sumBefore=$(calcOffsetSumInTopic)
cat ./benchmarkTransactions.json | ./sendToKafka.sh transactions
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

echo "Number of records in topic ${TOPIC}: "$((sumAfter - sumBefore))
echo $sumBefore
echo $sumAfter

