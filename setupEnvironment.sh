#!/usr/bin/env bash

echo "Process clear out"
#just in case
curl -X POST -u admin:admin 'http://localhost:8081/api/processManagement/cancel/DetectLargeTransactions'
curl -u admin:admin -X DELETE http://localhost:8081/api/processes/DetectLargeTransactions -v

main() {
  SCHEMA=$1
  echo "Starting docker containers"

  #just in case
  docker-compose -f docker-compose.yml -f docker-compose-env.yml kill
  docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
  docker-compose -f docker-compose.yml -f docker-compose-env.yml build
  docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate

  waitForOK "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
  waitForOK "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"
  waitForOK "flink/" "Checking Flink response.." "Flink not started" "jobmanager"
  waitForOK "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

  #Creating required schemas for DetectLargeTransactions
  ./testData/schema/createSchemas.sh

  echo "Creating process"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://admin:admin@localhost:8081/api/processes/DetectLargeTransactions/Default?isSubprocess=false")
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    docker logs nussknacker_designer
    exit 1
  fi

  echo "Importing scenario"
  RESPONSE=$(curl -s -F "process=@$SCHEMA" "http://admin:admin@localhost:8081/api/processes/import/DetectLargeTransactions")

  echo "Saving scenario"
  start='{"process":'
  end=',"comment": ""}'
  curl -s -o /dev/null -u admin:admin -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${start}${RESPONSE}${end}" -X PUT 'http://localhost:8081/api/processes/DetectLargeTransactions'

  echo "Deploying scenario"
  curl -u admin:admin -X POST 'http://localhost:8081/api/processManagement/deploy/DetectLargeTransactions' &

  echo "Waiting for status running"

  waitTime=0
  sleep=5
  waitLimit=120
  while [[ $waitTime -lt $waitLimit && $STATUS != 'RUNNING' ]]; do
    sleep "$sleep"
    waitTime=$((waitTime + sleep))

    STATUS=$(curl -s -u admin:admin -X GET 'http://localhost:8081/api/processes/DetectLargeTransactions/status' |
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

checkCode() {
  curl -s -o /dev/null -w "%{http_code}" "http://admin:admin@localhost:8081/$1"
}

waitForOK() {
  waitTime=0
  sleep=10
  waitLimit=120

  echo "$2"

  URL_PATH=$1
  STATUS_CODE=$(checkCode "$URL_PATH")
  CONTAINER_FOR_LOGS=$4

  while [[ $waitTime -lt $waitLimit && $STATUS_CODE != 200 ]]; do
    sleep $sleep
    waitTime=$((waitTime + sleep))
    STATUS_CODE=$(checkCode "$URL_PATH")

    if [[ $STATUS_CODE != 200 ]]; then
      echo "Service still not started within $waitTime sec and response code: $STATUS_CODE.."
    fi
  done
  if [[ $STATUS_CODE != 200 ]]; then
    echo "$3"
    docker-compose -f docker-compose-env.yml -f docker-compose.yml logs --tail=200 "$CONTAINER_FOR_LOGS"
    exit 1
  fi
}

main "$1"