#!/bin/bash

set -e

SLEEP=5
WAIT_LIMIT=60
SERVICE_ACCOUNT_AVAILABLE="false"
SERVICE_ACCOUNT_NAME="default"

waitTime=0

while [[ $waitTime -lt $WAIT_LIMIT && $SERVICE_ACCOUNT_AVAILABLE == "false" ]]; do
  if kubectl get serviceaccounts | grep -q "$SERVICE_ACCOUNT_NAME"; then
    SERVICE_ACCOUNT_AVAILABLE="true"
  else
    echo "Service account $SERVICE_ACCOUNT_NAME is still not available after $waitTime seconds."
    sleep $SLEEP
    waitTime=$((waitTime + $SLEEP))
  fi
done

if [[ $SERVICE_ACCOUNT_AVAILABLE == "false" ]]; then
  echo "Timeout after $WAIT_LIMIT seconds. Service account $SERVICE_ACCOUNT_NAME not available."
  exit 1
fi