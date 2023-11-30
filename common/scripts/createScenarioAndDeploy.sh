#!/bin/bash -ex

# This script allows to create and import scenario and at the end to deploy

cd "$(dirname "$0")"

TOOLSPATH="$(dirname "$0")"

if [[ -z $DOMAIN || -z $RELEASE ]]; then
  DESIGNER_URL=${DESIGNER_URL:-http://localhost:8081}
else 
  DESIGNER_URL=http://$RELEASE-nussknacker.$DOMAIN
fi

deploy() {
  SCENARIO_PATH=$1
  SCENARIO_NAME=$(source ./utils.sh && cat "$SCENARIO_PATH" | local_jq -r .metaData.id)
  TYPE_SPECIFIC_DATA=$(source ./utils.sh && cat "$SCENARIO_PATH" | local_jq -r .metaData.typeSpecificData.type)
  #Default authorization is basic encoded admin:admin
  AUTHORIZATION_HEADER_VALUE=${2:-"Basic YWRtaW46YWRtaW4="}
  AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"

  if [[ "$TYPE_SPECIFIC_DATA" == "FragmentSpecificData" ]]; then
     echo "Fragment can't be deployed.."
     exit 1
  fi

  echo "Deploying scenario $SCENARIO_NAME"
  curl -Lv -H "$AUTHORIZATION_HEADER" -X POST "$DESIGNER_URL/api/processManagement/deploy/$SCENARIO_NAME"
  
  echo "Waiting for status running"

  waitTime=0
  sleep=5
  waitLimit=120
  while [[ $waitTime -lt $waitLimit && $STATUS != 'RUNNING' ]]; do
    sleep "$sleep"
    waitTime=$((waitTime + sleep))

    RESPONSE=$(curl -s -L -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" -X GET "$DESIGNER_URL/api/processes/$SCENARIO_NAME/status")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    RESPNSE_BODY=$(echo "$RESPONSE" | sed \$d)

    if [[ "$HTTP_CODE" == 200 ]]; then
      STATUS=$(source ./utils.sh && echo "$RESPNSE_BODY" | local_jq -r .status.name)
      if [[ $STATUS == 'RUNNING' ]]; then
        echo "Scenario deployed within $waitTime sec"
        exit 0
      else
        echo "Scenario still not deployed within $waitTime sec with actual status: $STATUS.."
      fi
    else
      echo "Cannot check status code in this iteration. HTTP status: $HTTP_CODE"
    fi
  done
  
  if [[ "$STATUS" != 'RUNNING' ]]; then
    echo "Deployed scenario couldn't start running"
    "$TOOLSPATH/displayLogs.sh" runtime
    exit 1
  fi
}

# Create and import scenario
"$TOOLSPATH/createScenario.sh" "$1" "$2" "$3" "$4"

# With parameter that contains importing scheme file path
deploy "$1" "$2"
