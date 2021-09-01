#!/bin/bash

set -e

cd "$(dirname $0)"

echo "Starting docker containers"

docker-compose -f docker-compose.yml -f docker-compose-env.yml stop
docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
docker-compose -f docker-compose.yml -f docker-compose-env.yml build
docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate

./waitForOkFromUrl "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
./waitForOkFromUrl "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"
./waitForOkFromUrl "flink/" "Checking Flink response.." "Flink not started" "jobmanager"
./waitForOkFromUrl "metrics" "Checking Grafana response.." "Grafana not started" "grafana"
