#!/bin/bash -ex

cd "$(dirname "$0")"

echo "Restarting docker containers"

./invokeDocker.sh stop
./invokeDocker.sh rm -f -v
./invokeDocker.sh build
./invokeDocker.sh up -d --no-recreate --remove-orphans

../../common/scripts/waitForOkFromUrl.sh "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
../../common/scripts/waitForOkFromUrl.sh "api/processes/status" "Checking connect with engine.." "Nussknacker not connected with engine" "designer"
../../common/scripts/waitForOkFromUrl.sh "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

echo "Containers up and running"
