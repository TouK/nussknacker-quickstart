#!/bin/sh

set -e

cd "$(dirname "$0")"

./runInKafka.sh kafka-console-producer --topic "$1" --bootstrap-server localhost:9092
