#!/bin/bash -e

cd "$(dirname "$0")"

source ../../utils/lib.sh

if [ "$#" -ne 1 ]; then
    red_echo "ERROR: One parameter required: 1) scenario example folder path\n"
    exit 1
fi

function send_request() {
  if [ "$#" -ne 2 ]; then
    red_echo "ERROR: Two parameters required: 1) Request-Response OpenAPI service slug, 2) request body\n"
    exit 11
  fi

  set -e

  local OPENAPI_SERVICE_SLUG=$1
  local REQUEST_BODY=$2

  echo -n "Sending request '$REQUEST_BODY' to Request-Response '$OPENAPI_SERVICE_SLUG' OpenAPI service... "
  ../../utils/http/send-request-to-nu-openapi-service.sh "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY"
  echo "OK"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to send preconfigured Request-Response OpenAPI service requests..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/data/http/static"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.txt ]]; then
    red_echo "ERROR: Unrecognized file $ITEM. Required file with extension '.txt' and content with JSON messages\n"
    exit 3
  fi

  OPENAPI_SERVICE_SLUG=$(basename "$ITEM" ".txt")

  while IFS= read -r REQUEST_BODY; do
    if [[ $REQUEST_BODY == "#"* ]]; then
      continue
    fi

    send_request "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY"

  done < "$ITEM"
done

echo -e "Requests sent!\n"
