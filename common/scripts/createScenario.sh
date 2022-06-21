#!/usr/bin/env bash

set -e

if [ ! -f "$1" ]
then  
  echo "File $1 does not exist!"
  exit 1
fi

TOOLSPATH="$(dirname $0)"

if [[ -z $DOMAIN ]]; then
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
  CATEGORY=${3:-"Default"}
  FORCE_REMOVE=${4-"false"}

  TYPE_SPECIFIC_DATA=`cat $SCENARIO_PATH | jq -r .metaData.typeSpecificData.type`
  PROCESS_TYPE="Scenario"
  IS_FRAGMENT=false

  if [[ "$TYPE_SPECIFIC_DATA" == "FragmentSpecificData" ]]; then
    PROCESS_TYPE="Fragment"
    IS_FRAGMENT=true
  fi

  if [[ "$FORCE_REMOVE" == "true" ]]; then
    echo "Force removing $PROCESS_TYPE $SCENARIO_PATH.."

    if [[ "$IS_FRAGMENT" == "false" ]]; then
       curl -L -X POST -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processManagement/cancel/$SCENARIO_NAME"
    fi

    curl -L -H "$AUTHORIZATION_HEADER" -X DELETE "$DESIGNER_URL/api/processes/$SCENARIO_NAME" -v
  fi

  echo "Creating $PROCESS_TYPE $SCENARIO_PATH"
  CODE=$(curl -s -L -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" -X POST "$DESIGNER_URL/api/processes/$SCENARIO_NAME/$CATEGORY?isSubprocess=$IS_FRAGMENT")
  if [[ $CODE == 201 ]]; then
    echo "$PROCESS_TYPE creation success"
  elif [[ $CODE == 400 ]]; then
    echo "$PROCESS_TYPE has already exists in db."
  else
    echo "$PROCESS_TYPE creation failed with $CODE"
    echo " ------------------ Designer container logs below this line only -----------------------"
    $TOOLSPATH/displayLogs.sh designer
    exit 1
  fi

  echo "Importing $PROCESS_TYPE $SCENARIO_NAME"

  RESPONSE=$(curl -s -L -F "process=@$SCENARIO_PATH" -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processes/import/$SCENARIO_NAME")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  SCENARIO=$(echo "$RESPONSE" | sed \$d)
  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "Failed to import $PROCESS_TYPE"
    exit 1
  fi

  echo "Saving $PROCESS_TYPE $SCENARIO_NAME"
  START='{"process":'
  END=',"comment": ""}'
  curl -s -o /dev/null -L  -H "$AUTHORIZATION_HEADER" -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${START}${SCENARIO}${END}" -X PUT "$DESIGNER_URL/api/processes/$SCENARIO_NAME"

  echo "$PROCESS_TYPE successful created and saved.."
}

# With parameter that contains importing scheme file path
main "$1" "$2" "$3" "$4"
