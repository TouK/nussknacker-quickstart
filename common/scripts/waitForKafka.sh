#!/bin/bash -ex

cd "$(dirname "$0")"

TOPIC=${1}
RECORD_COUNT=${2}
SLEEP=${3-10}
WAIT_LIMIT=${4-120}

calcOffsetSumInTopic() {
  ./runInKafka.sh  kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic "$TOPIC" |
  grep -e ':[[:digit:]]*:' | awk -F ":" '{sum += $3} END {print sum}'
}

waitTime=0
offsetSum=$(calcOffsetSumInTopic)

while [[ $waitTime -lt $WAIT_LIMIT && ($offsetSum -lt $((RECORD_COUNT)))]]
do
  sleep "$SLEEP"
  waitTime=$((WAIT_LIMIT+SLEEP))
  offsetSum=$(calcOffsetSumInTopic)
  if [[ offsetSum -lt $((RECORD_COUNT)) ]]
  then
    echo "All records have yet not been obtained by kafka within $waitTime sec, $offsetSum records processed so far."
  fi
done

if [[ offsetSum -lt $RECORD_COUNT ]]
then
  echo "Records not obtained within time limit"
  exit 1
fi
