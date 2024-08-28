#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 2 ]; then
    echo -e "${RED}ERROR: Two parameters required: 1) topic name, 2) generator script path${RESET}\n"
    exit 1
fi

TOPIC=$1
GENERATOR_SCRIPT=$2

verifyBashScript "$GENERATOR_SCRIPT"

while true; do
  sleep 0.1
  ./send-to-topic.sh "$TOPIC" "$($GENERATOR_SCRIPT)" || true
done
