#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

echo "Starting docker containers.."

#just in case
docker-compose -f docker-compose.yml -f docker-compose-env.yml kill
docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
docker-compose -f docker-compose.yml -f docker-compose-env.yml build
docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate

trap 'docker-compose -f docker-compose.yml -f docker-compose-env.yml kill && docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v' EXIT

./testData/waitForOkFromUrl "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"

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

CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://admin:admin@localhost:8081/api/processCounts/DetectLargeTransactions?dateFrom=2021-08-04T00:00:00%2B02:00&dateTo=2021-08-04T23:59:59%2B02:00")
if [[ $CODE == 200 ]]; then
  echo "Counts queried"
else
  echo "Counts query failed with $CODE"
  docker logs nussknacker_designer
  exit 1
fi

./testData/waitForOkFromUrl "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"

./testData/waitForOkFromUrl "flink/" "Checking Flink response.." "Flink not started" "jobmanager"

./testData/waitForOkFromUrl "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

#TODO:
#check import process
#check test with test data

echo "Everything seems fine :)"

