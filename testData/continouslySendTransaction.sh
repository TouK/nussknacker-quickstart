#!/bin/sh

set -e

cd "$(dirname $0)"

while [ true ]; do
  sleep 0.1
  ID=$((1 + `tr -cd 0-9 </dev/urandom | head -c 4 | sed -e 's/^00*//'` % 5))
  AMOUNT=$((1 + `tr -cd 0-9 </dev/urandom | head -c 4 | sed -e 's/^00*//'` % 30))
  NOW=`date +%s%3N`
  TIME=$((NOW - `tr -cd 0-9 </dev/urandom | head -c 4 | sed -e 's/^00*//'` % 20))
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
done | ./sendToKafka.sh transactions
