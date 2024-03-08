#!/bin/bash -e

cd "$(dirname "$0")"

cat ../testData/DetectLargeTransactions-testData.json | ./sendToKafka.sh transactions
