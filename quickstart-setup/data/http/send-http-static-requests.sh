#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function sendRequest() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) Request-Response OpenAPI service slug, 2) request body"
    exit 11
  fi

  set -e

  local OPENAPI_SERVICE_SLUG=$1
  local REQUEST_BODY=$2

  echo "Sending request '$REQUEST_BODY' to Request-Response '$OPENAPI_SERVICE_SLUG' OpenAPI service ..."
  local RESPONSE
  RESPONSE=$(../../utils/http/send-request-to-nu-openapi-service.sh "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY")
  echo "Response: $RESPONSE"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to send preconfigured Request-Response OpenAPI service requests ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/data/http/static"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    echo "Unrecognized file $ITEM. Required file with extension '.txt' and content with JSON messages"
    exit 3
  fi

  OPENAPI_SERVICE_SLUG=$(basename "$ITEM" ".txt")

  while IFS= read -r REQUEST_BODY; do
    if [[ $REQUEST_BODY == "#"* ]]; then
      continue
    fi

    sendRequest "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY"

  done < "$ITEM"
done

echo -e "DONE!\n\n"
