#!/bin/bash

set -e

cd "$(dirname $0)"

CONTAINER_NAME=nussknacker_kafka
TOPIC=$1
PARTITION_COUNT=$2


docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --zookeeper zookeeper:2181 --partitions "$PARTITION_COUNT" --replication-factor 1 --if-not-exists
cat ./benchmarkTransactions.json | ./sendToKafka.sh transactions






#!/bin/bash

set -e

cd "$(dirname $0)"


echo "Starting docker containers.."

docker-compose -f docker-compose.yml -f docker-compose-env.yml kill
docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
docker-compose -f docker-compose.yml -f docker-compose-env.yml build
docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate

trap 'docker-compose -f docker-compose.yml -f docker-compose-env.yml kill && docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v' EXIT


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
./generateBenchmarkTransactions $CLIENTID_COUNT $TRANSACTIONS_PER_CLIENT $TIME_DEVIATION_PARAMETER

docker exec $CONTAINER_NAME kafka-topics.sh --create --topic "$TOPIC" --zookeeper zookeeper:2181 --partitions "$PARTITION_COUNT" --replication-factor 1 --if-not-exists

sumAfter=sumBefore=$(calcOffsetSumInTopic)
cat ./benchmarkTransactions.json | ./sendToKafka.sh transactions

waitTime=0
sleep=10
waitLimit=120
offsetSum=$((sumAfter - sumBefore))

while [[ $waitTime -lt $waitLimit && offsetSum -lt $TRANSACTION_COUNT]]
do
  sleep $sleep
  waitTime=$((waitTime+sleep))
  sumAfter=$(calcOffsetSumInTopic)
  allOffsetSum=$((sumAfter-sumBefore))
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

