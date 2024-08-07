#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -lt 2 ]; then
  echo "Error: Two parameters required: 1) scenario name, 2) scenario file path"
  exit 1
fi

SCENARIO_NAME=$1
SCENARIO_FILE_PATH=$2
CATEGORY=${3:-"Default"}

if [ ! -f "$SCENARIO_FILE_PATH" ]; then
  echo "Error: Cannot find file $SCENARIO_FILE_PATH with scenario"
  exit 2
fi

function createEmptyScenario() {
  if [ "$#" -ne 4 ]; then
      echo "Error: Four parameters required: 1) scenario name, 2) processing mode, 3) category, 4) engine"
      exit 11
  fi

  set -e

  local SCENARIO_NAME=$1
  local PROCESSING_MODE=$2
  local CATEGORY=$3
  local ENGINE=$4

  local REQUEST_BODY="{
    \"name\": \"$SCENARIO_NAME\",
    \"processingMode\": \"$PROCESSING_MODE\",
    \"category\": \"$CATEGORY\",
    \"engineSetupName\": \"$ENGINE\",
    \"isFragment\": false
  }"

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://nginx:8080/api/processes" \
    -H "Content-Type: application/json" -d "$REQUEST_BODY"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  if [ "$HTTP_STATUS" == "400" ]; then
    local RESPONSE_BODY
    RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
    
    if [[ "$RESPONSE_BODY" == *"already exists"* ]]; then
      echo "Scenario already exists."
      exit 0
    else
      echo -e "Error: Cannot create empty scenario $SCENARIO_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
      exit 12
    fi
  elif [ "$HTTP_STATUS" != "201" ]; then
    local RESPONSE_BODY
    RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
    echo -e "Error: Cannot create empty scenario $SCENARIO_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 12
  fi

  echo "Empty scenario $SCENARIO_NAME created successfully."
}

function importScenarioFromFile() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) scenario name, 2) scenario file path"
    exit 21
  fi

  set -e

  local SCENARIO_NAME=$1
  local SCENARIO_FILE=$2

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://nginx:8080/api/processes/import/$SCENARIO_NAME" \
    -F "process=@$SCENARIO_FILE"
  )

  # Check response body and status code
  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  local RESPONSE_BODY
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

  if [ "$HTTP_STATUS" == "200" ]; then
    local SCENARIO_GRAPH
    SCENARIO_GRAPH=$(echo "$RESPONSE_BODY" | jq '.scenarioGraph')
    echo "$SCENARIO_GRAPH"
  else
    echo -e "Error: Cannot import scenario $SCENARIO_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 22
  fi
}

function saveScenario() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) scenario name, 2) scenario graph JSON representation"
    exit 31
  fi

  set -e

  local SCENARIO_NAME=$1
  local SCENARIO_GRAPH_JSON=$2

  local REQUEST_BODY="{
    \"scenarioGraph\": $SCENARIO_GRAPH_JSON,
    \"comment\": \"\"
  }"

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X PUT "http://nginx:8080/api/processes/$SCENARIO_NAME" \
    -H "Content-Type: application/json" -d "$REQUEST_BODY"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  if [ "$HTTP_STATUS" != "200" ]; then
    local RESPONSE_BODY
    RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
    echo -e "Error: Cannot save scenario $SCENARIO_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 32
  fi

  echo "Scenario $SCENARIO_NAME saved successfully."
}

META_DATA_TYPE=$(jq -r .metaData.additionalFields.metaDataType < "$SCENARIO_FILE_PATH")
case "$META_DATA_TYPE" in
  "StreamMetaData")
    ENGINE="Flink"
    PROCESSING_MODE="Unbounded-Stream"
    ;;
  "LiteStreamMetaData")
    ENGINE="Lite Embedded"
    PROCESSING_MODE="Unbounded-Stream"
    ;;
  "RequestResponseMetaData")
    ENGINE="Lite Embedded"
    PROCESSING_MODE="Request-Response"
    ;;
  *)
    echo "Error: Cannot import scenario with metadata type: $META_DATA_TYPE"
    exit 2
    ;;
esac

createEmptyScenario "$SCENARIO_NAME" "$PROCESSING_MODE" "$CATEGORY" "$ENGINE"
SCENARIO_GRAPH=$(importScenarioFromFile "$SCENARIO_NAME" "$SCENARIO_FILE_PATH")
saveScenario "$SCENARIO_NAME" "$SCENARIO_GRAPH"
