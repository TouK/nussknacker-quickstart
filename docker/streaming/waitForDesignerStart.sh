#!/bin/bash -e

cd "$(dirname "$0")"

TIMEOUT_SECONDS=120
TIMEOUT_START=$(date +%s)
TIMEOUT_END=$((TIMEOUT_START + TIMEOUT_SECONDS))

echo "Waiting for Nu Designer start ..."

while true; do
    DESIGNER_STATUS=$(../common/invokeDocker.sh ps -q designer | xargs docker inspect -f '{{ .State.Health.Status }}')

    if [ "$DESIGNER_STATUS" == "healthy" ]; then
        echo "Nu Designer started!"
        break
    fi

    CURRENT_TIME=$(date +%s)

    if [ "$CURRENT_TIME" -ge "$TIMEOUT_END" ]; then
        echo "Nu Designer failed to started within $TIMEOUT_SECONDS seconds!"
        exit 1
    fi

    sleep 5
done