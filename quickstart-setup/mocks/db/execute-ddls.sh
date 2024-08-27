#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

source postgres-operations.sh
source ../../utils/lib.sh

function execute_ddl_script() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) DDL file path"
    exit 11
  fi

  set -e

  local DDL_FILE_NAME=$1

  local SCHEMA_NAME
  local DDL_CONTENT

  SCHEMA_NAME=$(basename "$(strip_extension "$DDL_FILE_NAME")")
  echo "Creating schema: $SCHEMA_NAME ..."
  create_schema "$PG_USER" "$SCHEMA_NAME" > /dev/null
  
  DDL_CONTENT=$(wrap_sql_with_current_schema "$SCHEMA_NAME" "$(cat "$DDL_FILE_NAME")")
  echo "Executing DDL '$DDL_FILE_NAME' ..."
  echo "$DDL_CONTENT" | execute_sql "" "$PG_USER" "$PG_PASS" > /dev/null
}

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

echo "Starting to import Postgres DDL scripts ..."

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/mocks/db"/*; do
  if [ -f "$ITEM" ]; then
    execute_ddl_script "$ITEM"
  fi
done

echo -e "DONE!\n\n"
