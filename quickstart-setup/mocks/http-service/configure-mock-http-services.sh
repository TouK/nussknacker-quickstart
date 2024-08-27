#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function copyFilesAndMappings() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) HTTP mocks folder path"
    exit 11
  fi

  set -e

  local MOCKS_FOLDER_NAME=$1
  
  mkdir -p /home/wiremock/mocks/__files/
  cp -r "$MOCKS_FOLDER_NAME/__files/." /home/wiremock/mocks/__files/
  
  mkdir -p /home/wiremock/mocks/mappings/
  cp -r "$MOCKS_FOLDER_NAME/mappings/." /home/wiremock/mocks/mappings/
}

function resetMappings() {
  RESPONSE=$(curl -s -L -w "\n%{http_code}" \
    -X POST "http://localhost:8080/__admin/mappings/reset" \
  )

  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

  if [[ "$HTTP_STATUS" != 200 ]] ; then
    echo -e "Cannot reset Wiremock mappings.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 12
  fi
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to configure Wiremock mappings and files ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/mocks/http-service"/*; do
  if [ -d "$ITEM" ]; then
    copyFilesAndMappings "$ITEM"
  fi
done

resetMappings

echo -e "DONE!\n\n"
