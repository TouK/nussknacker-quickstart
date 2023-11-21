#!/bin/bash -ex

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

cd "$(dirname "$0")"
set -a; source ../../k8s-helm/.env; set +a

WAIT_FOR_OK="../scripts/waitForOkFromUrl.sh"

source ../scripts/utils.sh

SCENARIO_PATH=$(fullPath "../../k8s-helm/scenarios/LoanRequest.json")

$WAIT_FOR_OK "api/processes" "Checking Nussknacker API response..." "Nussknacker not started" "designer"
$WAIT_FOR_OK  "metrics" "Checking Grafana response..." "Grafana not started" "grafana"
../scripts/createScenarioAndDeploy.sh "$SCENARIO_PATH"
$WAIT_FOR_OK  "api/processes/status" "Checking status..." "Scenario not running" "designer"
$WAIT_FOR_OK  "api/processCounts/LoanRequest?dateFrom=2021-08-04T00:00:00%2B02:00&dateTo=2021-08-04T23:59:59%2B02:00" "Checking counts" "Counts not working" "designer"

kubectl port-forward service/nu-quickstart-loan 3181:80 &
trap "jobs -p | xargs -r kill" SIGINT SIGTERM EXIT
../scripts/waitForPortAvailable.sh localhost 3181 10
curl -d '{customerId: "4", requestedAmount: 2000, requestType: "mortgage", location: { city: "Lublin", street: "Lipowa" }}' -HContent-Type:application/json -i -f http://localhost:3181

echo -e "\nEverything seems to be fine :)"
