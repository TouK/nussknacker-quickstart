#!/bin/bash -ex

cd "$(dirname "$0")"

cat ../testData/transactions.json | ./sendToKafka.sh transactions
