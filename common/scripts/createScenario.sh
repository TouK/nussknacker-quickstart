#!/bin/bash -e

# This script allows to create and import scenario

if [ ! -f "$1" ]
then  
  echo "File $1 does not exist!"
  exit 1
fi

cd "$(dirname "$0")"

TOOLSPATH="$(dirname "$0")"

if [[ -z $DOMAIN || -z $RELEASE ]]; then
  DESIGNER_URL=${DESIGNER_URL:-http://localhost:8081}
else 
  DESIGNER_URL=http://$RELEASE-nussknacker.$DOMAIN
fi

main() {
  SCENARIO_PATH=$1
  SCENARIO_NAME=$(source ./utils.sh && cat $SCENARIO_PATH | local_jq -r .metaData.id)
  #Default authorization is basic encoded admin:admin
  AUTHORIZATION_HEADER_VALUE=${2:-"Basic YWRtaW46YWRtaW4="}
  AUTHORIZATION_HEADER="authorization: $AUTHORIZATION_HEADER_VALUE"
  CATEGORY=${3:-"Default"}
  FORCE_REMOVE=${4-"false"}

  META_DATA_TYPE=$(source ./utils.sh && cat $SCENARIO_PATH | local_jq -r .metaData.additionalFields.metaDataType)

  # TODO: Replace usage of metaDataType by custom script parameters. Parameters should be parsed using getopt or similar
  if [[ "$META_DATA_TYPE" == "FragmentSpecificData" ]]; then
    echo "Currently fragments importing is not supported by this script"
    exit 3
  elif [[ "$META_DATA_TYPE" == "StreamMetaData" ]]; then
    ENGINE="Flink"
    PROCESSING_MODE="Unbounded-Stream"
  elif [[ "$META_DATA_TYPE" == "LiteStreamMetaData" ]]; then
    ENGINE="Lite K8s"
    PROCESSING_MODE="Unbounded-Stream"
  elif [[ "$META_DATA_TYPE" == "RequestResponseMetaData" ]]; then
    ENGINE="Lite K8s"
    PROCESSING_MODE="Request-Response"
  fi

  if [[ "$FORCE_REMOVE" == "true" ]]; then
    echo "Force removing scenario $SCENARIO_PATH.."

    curl -L -X POST -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processManagement/cancel/$SCENARIO_NAME"

    curl -L -H "$AUTHORIZATION_HEADER" -X DELETE "$DESIGNER_URL/api/processes/$SCENARIO_NAME" -v
  fi

  echo "Creating scenario with processing mode [$PROCESSING_MODE] and engine [$ENGINE] from file [$SCENARIO_PATH]"
  REQUEST=$(echo "{ \"name\": \"$SCENARIO_NAME\", \"processingMode\": \"$PROCESSING_MODE\", \"category\": \"$CATEGORY\", \"engineSetupName\": \"$ENGINE\", \"isFragment\": false }")
  CODE=$(echo "$REQUEST" | curl -s -L -o /dev/null -w "%{http_code}" -H "$AUTHORIZATION_HEADER" -X POST -H "Content-type: application/json" "$DESIGNER_URL/api/processes" -d @-)
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    echo " ------------------ Designer container logs below this line only -----------------------"
    "$TOOLSPATH/displayLogs.sh" designer
    exit 2
  fi

  echo "Importing scenario $SCENARIO_NAME"

  RESPONSE=$(curl -s -L -F "process=@$SCENARIO_PATH" -w "\n%{http_code}" -H "$AUTHORIZATION_HEADER" "$DESIGNER_URL/api/processes/import/$SCENARIO_NAME")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  SCENARIO=$(echo "$RESPONSE" | sed \$d  | jq .scenarioGraph)
  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "Failed to import scenario"
    exit 1
  fi

  echo "Saving scenario $SCENARIO_NAME"
  START='{"scenarioGraph":'
  END=',"comment": ""}'
  curl -s -o /dev/null -L  -H "$AUTHORIZATION_HEADER" -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw "${START}${SCENARIO}${END}" -X PUT "$DESIGNER_URL/api/processes/$SCENARIO_NAME"

  echo "Scenario successful created and saved.."
}

# With parameter that contains importing scheme file path
main "$1" "$2" "$3" "$4"
