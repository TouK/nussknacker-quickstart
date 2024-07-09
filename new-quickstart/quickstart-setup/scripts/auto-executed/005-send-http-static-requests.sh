#!/bin/bash -e

cd "$(dirname "$0")"

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
  RESPONSE=$(../utils/http/send-request-to-nu-openapi-service.sh "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY")
  echo "Response: $RESPONSE"
}

echo "Starting to send preconfigured Request-Response OpenAPI service requests ..."

while IFS= read -r OPENAPI_SERVICE_SLUG; do

  if [[ $OPENAPI_SERVICE_SLUG == "#"* ]]; then
    continue
  fi

  MESSAGES_FILE="../../data/http/static-requests/$OPENAPI_SERVICE_SLUG.txt"

  if [[ -f "$MESSAGES_FILE" ]]; then
    while IFS= read -r REQUEST_BODY; do
      if [[ $REQUEST_BODY == "#"* ]]; then
        continue
      fi

      sendRequest "$OPENAPI_SERVICE_SLUG" "$REQUEST_BODY"
    done < "$MESSAGES_FILE"
  fi

done < "../../data/http/slugs.txt"

echo -e "DONE!\n\n"
