#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "ERROR: One parameter required: 1) scenario example folder path"
    exit 1
fi

function createJsonSchema() {
  if [ "$#" -ne 2 ]; then
    echo "ERROR: Two parameters required: 1) schema name, 2) schema file path"
    exit 11
  fi

  set -e

  local SCHEMA_NAME=$1
  local SCHEMA_FILE_PATH=$2
  
  echo "Creating schema '$SCHEMA_NAME' ..."
  ../../utils/schema-registry/add-json-schema-idempotently.sh "$SCHEMA_NAME" "$SCHEMA_FILE_PATH"
  echo "Schema '$SCHEMA_NAME' created!"
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to add preconfigured schemas ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/setup/schema-registry"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.schema.json ]]; then
    echo "ERROR: Unrecognized file '$ITEM'. Required file with extension '.schema.json' and content with JSON schema"
    exit 2
  fi

  SCHEMA_NAME="$(basename "$ITEM" ".schema.json")-value"
  createJsonSchema "$SCHEMA_NAME" "$ITEM"
done

echo -e "DONE!\n\n"
