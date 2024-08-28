#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 2 ]; then
  echo -e "${RED}ERROR: Two parameters required: 1) Nu OpenAPI service slug, 2) request payload${RESET}\n"
  exit 1
fi

if ! [ -v NU_REQUEST_RESPONSE_OPEN_API_SERVICE_ADDRESS ] || [ -z "$NU_REQUEST_RESPONSE_OPEN_API_SERVICE_ADDRESS" ]; then
  echo -e "${RED}ERROR: required variable NU_REQUEST_RESPONSE_OPEN_API_SERVICE_ADDRESS not set or empty${RESET}\n"
  exit 2
fi

OPENAPI_SERVICE_SLUG=$1
REQUEST_BODY=$2

RESPONSE=$(curl -s -L -w "\n%{http_code}" \
  -X POST "http://$NU_REQUEST_RESPONSE_OPEN_API_SERVICE_ADDRESS/scenario/$OPENAPI_SERVICE_SLUG" \
  -H "Content-Type: application/json" -d "$REQUEST_BODY"
)

HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

if [[ "$HTTP_STATUS" != 200 ]] ; then
  echo -e "${RED}ERROR: '$OPENAPI_SERVICE_SLUG' OpenAPI service unexpected response.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY${RESET}\n"
  exit 3
fi

echo "$RESPONSE_BODY"