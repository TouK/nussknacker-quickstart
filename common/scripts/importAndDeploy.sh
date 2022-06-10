#!/usr/bin/env bash

set -e

if [ ! -f "$1" ]
then  
  echo "scenario $1 does not exist"
  exit 1
fi

TOOLSPATH"$(dirname $0)"

if [[ -z $DOMAIN ]]
then
DESIGNER_URL=${DESIGNER_URL:-http://localhost:8081}
else 
DESIGNER_URL=http://$RELEASE-nussknacker.$DOMAIN
fi

main() {
  SCENARIO_PATH=$1
  SCENARIO_NAME=`cat $SCENARIO_PATH | jq -r .metaData.id`
  #Default authorization is basic encoded admin:admin
  AUTHORIZATION_HEADER_VALUE=${2:-"Basic YWRtaW46YWRtaW4="}
  AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"


  curl -L -X POST -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processManagement/cancel/$SCENARIO_NAME"
  curl -L -H "$AUTHORIZATION_HEADER" -X DELETE "$DESIGNER_URL/api/processes/$SCENARIO_NAME" -v

  echo "Creating empty scenario $SCENARIO_PATH"
  CODE=$(curl -s -L -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" -X POST "$DESIGNER_URL/api/processes/$SCENARIO_NAME/Default?isSubprocess=false")
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    echo " ------------------ Designer container logs below this line only -----------------------"
    $TOOLSPATH/displayLogs.sh designer
    exit 1
  fi

  echo "Importing scenario $SCENARIO_NAME"

  RESPONSE=$(curl -s -L -F "process=@$SCENARIO_PATH" -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processes/import/$SCENARIO_NAME")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  SCENARIO=$(echo "$RESPONSE" | sed \$d)
  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "Failed to import scenario"
    exit 1
  fi

  echo "Saving scenario $SCENARIO_NAME"
  START='{"process":'
  END=',"comment": ""}'
  curl -s -o /dev/null -L  -H "$AUTHORIZATION_HEADER" -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${START}${SCENARIO}${END}" -X PUT "$DESIGNER_URL/api/processes/$SCENARIO_NAME"

  echo "Deploying scenario $SCENARIO_NAME"
  curl -H "$AUTHORIZATION_HEADER" -L -X POST "$DESIGNER_URL/api/processManagement/deploy/$SCENARIO_NAME" &

  echo "Waiting for status running"

  waitTime=0
  sleep=5
  waitLimit=120
  while [[ $waitTime -lt $waitLimit && $STATUS != 'RUNNING' ]]; do
    sleep "$sleep"
    waitTime=$((waitTime + sleep))

    STATUS=$(curl -s -L  -H "$AUTHORIZATION_HEADER" -X GET "$DESIGNER_URL/api/processes/$SCENARIO_NAME/status" | jq -r .status.name)
    if [[ $STATUS == 'RUNNING' ]]; then
      echo "Process deployed within $waitTime sec"
      exit 0
    else
      echo "Process still not deployed within $waitTime sec with actual status: $STATUS.."
    fi
  done
  if [[ "$STATUS" != 'RUNNING' ]]; then
    echo "Deployed scenario couldn't start running"
    $TOOLSPATH/displayLogs.sh runtime
    exit 1
  fi
}

# With parameter that contains importing scheme file path
main "$1" "$2"
