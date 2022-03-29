#!/bin/bash

set -e
cd "$(dirname $0)"

WAIT_FOR_OK="../scripts/waitForOkFromUrl.sh"
SCENARIO_PATH=$1

$WAIT_FOR_OK "api/processes" "Checking Nussknacker API response..." "Nussknacker not started" "designer"
$WAIT_FOR_OK  "metrics" "Checking Grafana response..." "Grafana not started" "grafana"

echo "Creating topics and schema"
../scripts/runInKafka.sh kafka-topics.sh --create --topic alerts --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
../schemas/createSchemas.sh
echo "Topic and schemas created"
../scripts/importAndDeploy.sh $SCENARIO_PATH 
$WAIT_FOR_OK  "api/processes/status" "Checking status..." "Scenario not running" "designer"
$WAIT_FOR_OK  "api/processCounts/DetectLargeTransactions?dateFrom=2021-08-04T00:00:00%2B02:00&dateTo=2021-08-04T23:59:59%2B02:00" "Checking counts" "Counts not working" "designer"
$WAIT_FOR_OK  "akhq/api/nussknacker/topic" "AKHQ not working" "akhq"

#TODO:
#check test with test data

echo "Everything seems fine :)"