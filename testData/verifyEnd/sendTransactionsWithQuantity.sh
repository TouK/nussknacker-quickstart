#!/bin/bash

set -e

cd "$(dirname $0)"

RANGE=$1
for i in $(seq 1 "$RANGE"); do
  sleep 0.1
  ID=$((1 + RANDOM % 5))
  AMOUNT=$((1 + RANDOM % 30))
  NOW=$(date +%s%3N)
  TIME=$((NOW - RANDOM % 20))
  if [ "$i" == "$RANGE" ]; then
    echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"isLast\": true, \"eventDate\": $TIME}"
  else
    echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
  fi
done | ./../sendToKafka.sh transactions
