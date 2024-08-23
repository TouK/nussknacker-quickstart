#!/bin/bash -e

cd "$(dirname "$0")"

/app/data/http/send-http-static-requests.sh
/app/data//kafka/send-kafka-static-messages.sh

/app/data//http/continuously-send-http-generated-requests.sh
/app/data//kafka/continuously-send-kafka-generated-messages.sh