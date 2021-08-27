#!/bin/bash

set -e

cd "$(dirname $0)"

TRANSACTION_COUNT=${1:-1000}
CLIENT_COUNT=${2:-10}
TIME_SPREAD_MULTIPLIER=${3:-10}

TIME_SPREAD_MILLIS=$((1000*60*TIME_SPREAD_MULTIPLIER))

for ((i=0;i<TRANSACTION_COUNT;i++));
do
  ID=$((1 + i % CLIENT_COUNT))
  AMOUNT=$((1 + i % 30))
  NOW=`date +%s%3N`
  TIME=$((NOW + (TIME_SPREAD_MILLIS * i) / TRANSACTION_COUNT))
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
done

# for now we treat last record as a flag, information that all data has been processed, but in the end we need better indicator
# we can't be sure our last send record will be flink's last processed, especially with multiple partitions on kafka topic
LAST_RECORD_TIMESTAMP=$((`date +%s%3N` + TIME_SPREAD_MILLIS))
LAST_RECORD_MARK="-1"
echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $LAST_RECORD_TIMESTAMP, \"description\": \"$LAST_RECORD_MARK\"}"

