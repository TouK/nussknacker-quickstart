#!/bin/bash

set -e

cd "$(dirname $0)"

echo "Restarting docker containers"

docker-compose -f docker-compose.yml -f docker-compose-env.yml stop
docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
docker-compose -f docker-compose.yml -f docker-compose-env.yml build
docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate --remove-orphans

../scripts/waitForOkFromUrl.sh "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
../scripts/waitForOkFromUrl.sh "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"
../scripts/waitForOkFromUrl.sh "flink/" "Checking Flink response.." "Flink not started" "runtime"
../scripts/waitForOkFromUrl.sh "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

echo "Containers up and running"
