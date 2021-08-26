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
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
  if [ "$i" == "$RANGE" ]; then
    echo "{ \"clientId\": \"999\", \"amount\": 999, \"eventDate\": $TIME}"
  fi
done | ./../sendToKafka.sh transactions
