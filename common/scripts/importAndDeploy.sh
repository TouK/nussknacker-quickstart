#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

if [[ -z $DOMAIN ]]
then
DESIGNER_URL=${DESIGNER_URL:-http://localhost:8081}
else 
DESIGNER_URL=http://$RELEASE-nussknacker.$DOMAIN
fi

main() {
  SCHEMA=$1
  #Default authorization is basic encoded admin:admin
  AUTHORIZATION_HEADER_VALUE=${2:-"Basic YWRtaW46YWRtaW4="}
  AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"

  curl -L -X POST -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processManagement/cancel/DetectLargeTransactions"
  curl -L -H "$AUTHORIZATION_HEADER" -X DELETE "$DESIGNER_URL/api/processes/DetectLargeTransactions" -v

  echo "Creating empty scenario $SCHEMA"
  CODE=$(curl -s -L -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" -X POST "$DESIGNER_URL/api/processes/DetectLargeTransactions/Default?isSubprocess=false")
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    ./displayLogs.sh designer
    exit 1
  fi

  echo "Creating required schemas for $SCHEMA"
  ../schemas/createSchemas.sh

  echo "Importing scenario $SCHEMA"

  RESPONSE=$(curl -s -L -F "process=@$SCHEMA" -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processes/import/DetectLargeTransactions")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  SCENARIO=$(echo "$RESPONSE" | sed \$d)
  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "Failed to import scenario"
    exit 1
  fi

  echo "Saving scenario $SCHEMA"
  START='{"process":'
  END=',"comment": ""}'
  curl -s -o /dev/null -L  -H "$AUTHORIZATION_HEADER" -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${START}${SCENARIO}${END}" -X PUT "$DESIGNER_URL/api/processes/DetectLargeTransactions"

  echo "Deploying scenario $SCHEMA"
  curl -H "$AUTHORIZATION_HEADER" -L -X POST "$DESIGNER_URL/api/processManagement/deploy/DetectLargeTransactions" &

  echo "Waiting for status running"

  waitTime=0
  sleep=5
  waitLimit=120
  while [[ $waitTime -lt $waitLimit && $STATUS != 'RUNNING' ]]; do
    sleep "$sleep"
    waitTime=$((waitTime + sleep))

    STATUS=$(curl -s -L  -H "$AUTHORIZATION_HEADER" -X GET "$DESIGNER_URL/api/processes/DetectLargeTransactions/status" | jq -r .status.name)
    if [[ $STATUS == 'RUNNING' ]]; then
      echo "Process deployed within $waitTime sec"
      exit 0
    else
      echo "Process still not deployed within $waitTime sec with actual status: $STATUS.."
    fi
  done
  if [[ "$STATUS" != 'RUNNING' ]]; then
    echo "Deployed scenario couldn't start running"
    ./displayLogs.sh runtime
    exit 1
  fi
}

# With parameter that contains importing scheme file path
main "$1" "$2"
