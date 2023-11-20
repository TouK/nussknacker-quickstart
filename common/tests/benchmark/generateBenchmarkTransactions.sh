#!/bin/bash -ex

cd "$(dirname "$0")"

TRANSACTION_COUNT=${1:-1000}
CLIENT_COUNT=${2:-10}
TIME_SPREAD_MULTIPLIER=${3:-10}

TIME_SPREAD_MILLIS=$((1000*60*TIME_SPREAD_MULTIPLIER))

FRAUDULENT_CLIENT_ID=1
NOW=$(date +%s%3N)

for ((i=0;i<TRANSACTION_COUNT;i++));
do
  ID=$((1 + i % CLIENT_COUNT))
  if [[ $ID == "$FRAUDULENT_CLIENT_ID" ]]
  then
    AMOUNT=$((31 + i % 300))
  else
    AMOUNT=$((1 + i % 30))
  fi
  TIME=$((NOW + (TIME_SPREAD_MILLIS * i) / TRANSACTION_COUNT))
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
done

# for now we treat last record as a flag, information that all data has been processed, but in the end we need better indicator
# we can't be sure our last send record will be flink's last processed, especially with multiple partitions on kafka topic
LAST_RECORD_TIMESTAMP=$((NOW + TIME_SPREAD_MILLIS))
echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"isLast\": true, \"eventDate\": $LAST_RECORD_TIMESTAMP}"
