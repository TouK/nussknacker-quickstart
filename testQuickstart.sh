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

./testData/waitForOkFromUrl.sh "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"

./testData/waitForOkFromUrl.sh  "flink/" "Checking Flink response.." "Flink not started" "jobmanager"

./testData/waitForOkFromUrl.sh  "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

./testData/importAndDeploy.sh ./DetectLargeTransactionsWithAggregation.json

./testData/waitForOkFromUrl.sh  "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"

CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://admin:admin@localhost:8081/api/processCounts/DetectLargeTransactions?dateFrom=2021-08-04T00:00:00%2B02:00&dateTo=2021-08-04T23:59:59%2B02:00")
if [[ $CODE == 200 ]]; then
  echo "Counts queried"
else
  echo "Counts query failed with $CODE"
  docker logs nussknacker_designer
  exit 1
fi

#TODO:
#check test with test data

echo "Everything seems fine :)"

