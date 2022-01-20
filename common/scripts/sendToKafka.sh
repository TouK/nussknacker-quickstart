#!/bin/sh

set -e

cd "$(dirname $0)"

./runInKafka.sh kafka-console-producer.sh --topic $1 --broker-list localhost:9092
