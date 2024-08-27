#!/bin/bash -ex

if [ "$#" -ne 2 ]; then
    echo "Two parameters required: 1) Nu OpenAPI service slug, 2) request payload"
    exit 1
fi

cd "$(dirname "$0")"

OPENAPI_SERVICE_SLUG=$1
REQUEST_BODY=$2

RESPONSE=$(curl -s -L -w "\n%{http_code}" \
  -X POST "http://nginx:8181/scenario/$OPENAPI_SERVICE_SLUG" \
  -H "Content-Type: application/json" -d "$REQUEST_BODY"
)

HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

if [[ "$HTTP_STATUS" != 200 ]] ; then
  echo -e "'$OPENAPI_SERVICE_SLUG' OpenAPI service unexpected response.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
  exit 12
fi

echo "$RESPONSE_BODY"