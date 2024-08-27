#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function copyFilesAndMappings() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) HTTP service name, 2) mocks folder path"
    exit 11
  fi

  set -e

  local HTTP_SERVICE_NAME=$1
  local MOCKS_FOLDER_NAME=$2 

  shopt -s nullglob
  
  mkdir -p /home/wiremock/mocks/__files/
  cp -r "$MOCKS_FOLDER_NAME/__files"/* /home/wiremock/mocks/__files/
  
  mkdir -p /home/wiremock/mocks/mappings/
  cp -r "$MOCKS_FOLDER_NAME/mappings"/* /home/wiremock/mocks/mappings/
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/mocks/http-service"/*; do
  if [ -d "$ITEM" ]; then
    # todo: remove?
    HTTP_SERVICE_NAME=$(basename "$ITEM")

    copyFilesAndMappings "$HTTP_SERVICE_NAME" "$ITEM"
  fi
done
