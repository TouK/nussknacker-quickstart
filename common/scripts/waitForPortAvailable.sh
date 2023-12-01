#!/bin/bash -ex

cd "$(dirname "$0")"

HOST=$1
PORT=$2
WAIT_LIMIT=$3
SLEEP=1

waitTime=0

while [[ $waitTime -lt $WAIT_LIMIT ]] && ! nc -z "$HOST" "$PORT"; do
  sleep $SLEEP
  waitTime=$((waitTime + "$SLEEP"))
  echo "Port $PORT on host $HOST still not available"
done
if ! nc -z "$HOST" "$PORT"; then
  echo "Waiting limit exhausted"
  exit 1
fi

echo "OK"