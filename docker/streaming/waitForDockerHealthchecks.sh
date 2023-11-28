#!/bin/bash -e

cd "$(dirname "$0")"

source ../../common/scripts/utils.sh

export BASE_PATH=$(pwd)
export ADDITIONAL_COMPOSE_FILE="-f $(fullPath ./docker-compose-streaming.yml)"

SLEEP=${1-10}
WAIT_LIMIT=${2-120}
UNHEALTHY="x"

waitTime=0

while [[ $waitTime -lt $WAIT_LIMIT && "x$UNHEALTHY" != "x" ]]; do
  waitTime=$((waitTime + $SLEEP))
  STATUSES=$(docker inspect --format='{{.Name}}:{{if .State.Health }}{{.State.Health.Status}}{{ else }}healthy{{ end }}' $(../common/invokeDocker.sh ps -q))
  UNHEALTHY=$(echo "$STATUSES" | sed 's/\///g' | tr ' ' '\n' | grep -v ':healthy' | tr '\n' ' ')
  if [[ "x$UNHEALTHY" != "x" ]]; then
    echo "Some services still not healthy: $UNHEALTHY"
    sleep $SLEEP
  fi
done

if [[ "x$UNHEALTHY" != "x" ]]; then
  echo "Some services not healthy: $UNHEALTHY"
  exit 1
fi

echo "All healthy"