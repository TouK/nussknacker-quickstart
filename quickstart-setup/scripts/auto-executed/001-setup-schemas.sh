#!/bin/bash -e

cd "$(dirname "$0")"

function createJsonSchema() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) schema name, 2) schema file path"
    exit 11
  fi

  set -e

  local SCHEMA_NAME=$1
  local SCHEMA_FILE=$2

  echo "Creating schema '$SCHEMA_NAME' ..."
  ESCAPED_JSON_SCHEMA=$(awk 'BEGIN{ORS="\\n"} {gsub(/"/, "\\\"")} 1' < "$SCHEMA_FILE")

  local REQUEST_BODY="{
    \"schema\": \"$ESCAPED_JSON_SCHEMA\",
    \"schemaType\": \"JSON\",
    \"references\": []
  }"

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://schema-registry:8081/subjects/${SCHEMA_NAME}/versions" \
    -H "Content-Type: application/vnd.schemaregistry.v1+json" -d "$REQUEST_BODY"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  if [[ "$HTTP_STATUS" != 200 ]] ; then
    local RESPONSE_BODY
    RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)
    echo -e "Error: Cannot create schema $SCHEMA_NAME.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 12
  fi

  echo "Schema '$SCHEMA_NAME' created!"
}

echo "Starting to add preconfigured schemas ..."

while IFS= read -r SCHEMA_FILENAME; do

  if [[ $SCHEMA_FILENAME == "#"* ]]; then
    continue
  fi

  SCHEMA_NAME="$(basename "$SCHEMA_FILENAME" ".schema.json")-value"
  createJsonSchema "$SCHEMA_NAME" "$(realpath ../../setup/schema-registry/schemas/"$SCHEMA_FILENAME")"

done < "../../setup/schema-registry/active-schemas.txt"


echo -e "DONE!\n\n"
