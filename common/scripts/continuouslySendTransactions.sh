#!/bin/sh

set -e

cd "$(dirname $0)"


random_number() {
  tr -cd 0-9 </dev/urandom | head -c 4 | sed -E 's/^00*([0-9]+)/\1/'
}

while [ true ]; do
  sleep 0.1
  ID=$((1 + `random_number` % 5))
  AMOUNT=$((1 + `random_number` % 30))
  NOW=`date +%s%3N`
  TIME=$((NOW - `random_number` % 20))
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}" | ./sendToKafka.sh transactions
  echo -n "."
done
echo ""
