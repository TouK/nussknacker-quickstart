#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -lt 1 ]; then
  red_echo "ERROR: One parameter required: 1) scenario name\n"
  exit 1
fi

if ! [ -v NU_DESIGNER_ADDRESS ] || [ -z "$NU_DESIGNER_ADDRESS" ]; then
  red_echo "ERROR: required variable NU_DESIGNER_ADDRESS not set or empty\n"
  exit 2
fi

SCENARIO_NAME=$1
TIMEOUT_SECONDS=${2:-60}
WAIT_INTERVAL=5

function deploy_scenario() {
  if [ "$#" -ne 1 ]; then
      red_echo "ERROR: One parameter required: 1) scenario name\n"
      exit 11
  fi

  set -e

  local SCENARIO_NAME=$1

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://${NU_DESIGNER_ADDRESS}/api/processManagement/deploy/$SCENARIO_NAME"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  if [ "$HTTP_STATUS" != "200" ]; then
    local RESPONSE_BODY
    RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
    red_echo "ERROR: Cannot run scenario $SCENARIO_NAME deployment.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY\n"
    exit 12
  fi

  echo "Scenario $SCENARIO_NAME deployment started..."
}

function check_deployment_status() {
  if [ "$#" -ne 1 ]; then
    red_echo "ERROR: One parameter required: 1) scenario name\n"
    exit 21
  fi

  set -e

  local SCENARIO_NAME=$1

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X GET "http://${NU_DESIGNER_ADDRESS}/api/processes/$SCENARIO_NAME/status"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
  local RESPONSE_BODY
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

  if [ "$HTTP_STATUS" != "200" ]; then
    red_echo "ERROR: Cannot check scenario $SCENARIO_NAME deployment status.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY\n"
    exit 22
  fi

  local SCENARIO_STATUS
  SCENARIO_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status.name')
  echo "$SCENARIO_STATUS"
}

echo "Deploying scenario $SCENARIO_NAME..."

START_TIME=$(date +%s)
END_TIME=$((START_TIME + TIMEOUT_SECONDS))

deploy_scenario "$SCENARIO_NAME"

while true; do
  DEPLOYMENT_STATUS=$(check_deployment_status "$SCENARIO_NAME")

  if [ "$DEPLOYMENT_STATUS" == "RUNNING" ]; then
    break
  fi

  CURRENT_TIME=$(date +%s)
  if [ $CURRENT_TIME -gt $END_TIME ]; then
    red_echo "ERROR: Timeout for waiting for the RUNNING state of $SCENARIO_NAME deployment reached!\n"
    exit 3
  fi

  echo "$SCENARIO_NAME deployment state is $DEPLOYMENT_STATUS. Checking again in $WAIT_INTERVAL seconds..."
  sleep $WAIT_INTERVAL
done

echo "Scenario $SCENARIO_NAME is RUNNING!"
