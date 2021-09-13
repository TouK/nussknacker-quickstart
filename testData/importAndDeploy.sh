#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

main() {
  SCHEMA=${1:-"./benchmark/DetectLargeTransactionsWithFinishVerification.json"}
  #Default authorization is basic encoded admin:admin
  AUTHORIZATION_HEADER_VALUE=${2:-"Basic YWRtaW46YWRtaW4="}
  AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"

  curl -X POST -H "$AUTHORIZATION_HEADER" 'http://localhost:8081/api/processManagement/cancel/DetectLargeTransactions'
  curl -H "$AUTHORIZATION_HEADER" -X DELETE 'http://localhost:8081/api/processes/DetectLargeTransactions' -v

  echo "Creating empty scenario $SCHEMA"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" -X POST "http://localhost:8081/api/processes/DetectLargeTransactions/Default?isSubprocess=false")
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    docker logs "$(docker ps | grep nussknacker_designer | awk '{print $1}')"
    exit 1
  fi

  echo "Creating required schemas for $SCHEMA"
  ./schema/createSchemas.sh

  echo "Importing scenario $SCHEMA"
  RESPONSE=$(curl -s -F "process=@$SCHEMA" -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" "http://localhost:8081/api/processes/import/DetectLargeTransactions")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  SCENARIO=$(echo "$RESPONSE" | sed \$d)
  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "Failed to import scenario"
    exit 1
  fi

  echo "Saving scenario $SCHEMA"
  START='{"process":'
  END=',"comment": ""}'
  curl -s -o /dev/null -H "$AUTHORIZATION_HEADER" -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${START}${SCENARIO}${END}" -X PUT 'http://localhost:8081/api/processes/DetectLargeTransactions'

  echo "Deploying scenario $SCHEMA"
  curl -H "$AUTHORIZATION_HEADER" -X POST 'http://localhost:8081/api/processManagement/deploy/DetectLargeTransactions' &

  echo "Waiting for status running"

  waitTime=0
  sleep=5
  waitLimit=120
  while [[ $waitTime -lt $waitLimit && $STATUS != 'RUNNING' ]]; do
    sleep "$sleep"
    waitTime=$((waitTime + sleep))

    STATUS=$(curl -s -H "$AUTHORIZATION_HEADER" -X GET 'http://localhost:8081/api/processes/DetectLargeTransactions/status' |
      python3 -c "import sys, json; print(json.load(sys.stdin)['status']['name'])")
    if [[ $STATUS == 'RUNNING' ]]; then
      echo "Process deployed within $waitTime sec"
      exit 0
    else
      echo "Process still not deployed within $waitTime sec with actual status: $STATUS.."
    fi
  done
  if [[ "$STATUS" != 'RUNNING' ]]; then
    echo "Deployed scenario couldn't start running"
    exit 1
  fi
}

# With parameter that contains importing scheme file path
main "$1" "$2"
