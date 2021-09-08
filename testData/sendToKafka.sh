#!/bin/bash

set -e

cd "$(dirname $0)"

#TODO: is it always this?
CONTAINER_NAME=$(docker ps | grep nussknacker_kafka | awk '{print $1}')
docker exec -i $CONTAINER_NAME kafka-console-producer.sh --topic $1 --broker-list localhost:9092
