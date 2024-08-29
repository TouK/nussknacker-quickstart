#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 2 ]; then
  red_echo "ERROR: Two parameters required: 1) schema name, 2) schema file path\n"
  exit 1
fi

if ! [ -v SCHEMA_REGISTRY_ADDRESS ] || [ -z "$SCHEMA_REGISTRY_ADDRESS" ]; then
  red_echo "ERROR: required variable SCHEMA_REGISTRY_ADDRESS not set or empty\n"
  exit 2
fi

SCHEMA_NAME=$1
SCHEMA_FILE=$2

ESCAPED_JSON_SCHEMA=$(awk 'BEGIN{ORS="\\n"} {gsub(/"/, "\\\"")} 1' < "$SCHEMA_FILE")

REQUEST_BODY="{
  \"schema\": \"$ESCAPED_JSON_SCHEMA\",
  \"schemaType\": \"JSON\",
  \"references\": []
}"

RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
  -X POST "http://${SCHEMA_REGISTRY_ADDRESS}/subjects/${SCHEMA_NAME}/versions" \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" -d "$REQUEST_BODY"
)

HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

if [[ "$HTTP_STATUS" != 200 ]] ; then
  RESPONSE_BODY
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
  red_echo "ERROR: Cannot create schema $SCHEMA_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY\n"
  exit 3
fi