#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "One parameter required: 1) topic name"
    exit 1
fi

cd "$(dirname "$0")"

TOPIC_NAME=$1

/opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --if-not-exists --topic "$TOPIC_NAME"