#!/bin/bash

set -e

cd "$(dirname $0)"

CLIENTID_COUNT=${1:-100}
TRANSACTIONS_PER_CLIENT=${2:-10}
TRANSACTION_COUNT=$((CLIENTID_COUNT * TRANSACTIONS_PER_CLIENT))
TIME_DEVIATION_PARAMETER=${3:-10}
WINDOW_LENGTH=2000 #still don't know window length so using completely arbitrary value

for ((i=1;i<=TRANSACTION_COUNT;i++));
do
  ID=$((1 + RANDOM % CLIENTID_COUNT))
  AMOUNT=$((1 + RANDOM % 30))
  NOW=`date +%s%3N`
  TIME=$((NOW - RANDOM % (WINDOW_LENGTH*TIME_DEVIATION_PARAMETER)))
  echo "{ \"clientId\": \"$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"
done > benchmarkTransactions.json

