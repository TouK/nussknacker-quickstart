#!/bin/bash

set -e

cd "$(dirname "$0")"

URL_PATH=$1
MSG_INIT=$2
MSG_FAIL=$3
CONTAINER_FOR_LOGS=$4
SLEEP=${5-10}
WAIT_LIMIT=${6-120}

if [[ -z $DOMAIN || -z $RELEASE ]]
then
DESIGNER_URL=${DESIGNER_URL:-http://localhost:8081}
else 
DESIGNER_URL=http://$RELEASE-nussknacker.$DOMAIN
fi

AUTHORIZATION_HEADER_VALUE=${AUTHORIZATION_HEADER_VALUE:-"Basic YWRtaW46YWRtaW4="}
AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"

function checkCode() {
  curl -L -s -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/$URL_PATH" || true
}

waitTime=0
echo "$MSG_INIT: $DESIGNER_URL/$URL_PATH"

STATUS_CODE=$(checkCode)

while [[ $waitTime -lt $WAIT_LIMIT && $STATUS_CODE != 200 ]]; do
  sleep $SLEEP
  waitTime=$((waitTime + $SLEEP))
  STATUS_CODE=$(checkCode)

  if [[ $STATUS_CODE != 200 ]]; then
    echo "Service still not started within $waitTime sec and response code: $STATUS_CODE.."
  fi
done
if [[ $STATUS_CODE != 200 ]]; then
  echo "$MSG_FAIL"
  ./displayLogs.sh "$CONTAINER_FOR_LOGS"
  exit 1
fi

echo "OK"