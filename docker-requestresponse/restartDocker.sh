#!/bin/bash

set -e

cd "$(dirname $0)"

echo "Restarting docker containers"

docker-compose -f docker-compose.yml -f docker-compose-env.yml stop
docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
docker-compose -f docker-compose.yml -f docker-compose-env.yml build
docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate --remove-orphans

../common/scripts/waitForOkFromUrl.sh "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
../common/scripts/waitForOkFromUrl.sh "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

echo "Containers up and running"
