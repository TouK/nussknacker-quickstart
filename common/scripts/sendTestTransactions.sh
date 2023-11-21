#!/bin/bash -e

cd "$(dirname "$0")"

cat ../testData/transactions.json | ./sendToKafka.sh transactions
