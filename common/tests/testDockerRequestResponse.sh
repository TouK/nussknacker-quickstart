#!/bin/bash

set -e
cd "$(dirname $0)"

WAIT_FOR_OK="../scripts/waitForOkFromUrl.sh"
SCENARIO_PATH=`realpath ../../docker/requestresponse/scenarios/LoanRequest.json`

$WAIT_FOR_OK "api/processes" "Checking Nussknacker API response..." "Nussknacker not started" "designer"
$WAIT_FOR_OK  "metrics" "Checking Grafana response..." "Grafana not started" "grafana"
../scripts/createScenarioAndDeploy.sh $SCENARIO_PATH
$WAIT_FOR_OK  "api/processes/status" "Checking status..." "Scenario not running" "designer"
$WAIT_FOR_OK  "api/processCounts/Loan%20request?dateFrom=2021-08-04T00:00:00%2B02:00&dateTo=2021-08-04T23:59:59%2B02:00" "Checking counts" "Counts not working" "designer"

curl -d '{customerId: "4", requestedAmount: 2000, requestType: "mortgage", location: { city: "Lublin", street: "Lipowa" }}' -f -v http://localhost:3181/scenario/loan

echo "Everything seems fine :)"
