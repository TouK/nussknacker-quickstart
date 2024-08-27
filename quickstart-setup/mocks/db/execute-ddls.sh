#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

function execute_ddls() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) DB name, 2) DDLs folder path"
    exit 11
  fi

  set -e

  local DB_NAME=$1
  local DDLs_FOLDER_NAME=$2

  local SCHEMA_NAME
  local DDL_CONTENT

  shopt -s nullglob
  for file in "$DDLs_FOLDER_NAME"/*; do
    if [ -f "$file" ]; then
      SCHEMA_NAME=$(basename "$(strip_extension "$file")")
      echo "Creating schema: $SCHEMA_NAME"
      create_schema "$PG_USER" "$SCHEMA_NAME"
      DDL_CONTENT=$(wrap_sql_with_current_schema "$SCHEMA_NAME" "$(cat "$file")")
      echo "Executing ddl: $file with content: $DDL_CONTENT"
      echo "$DDL_CONTENT" | execute_sql "" "$PG_USER" "$PG_PASS"
    fi
  done
}

source postgres-operations.sh
source ../../utils/lib.sh

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/mocks/db"/*; do
  if [ -f "$ITEM" ]; then
    continue
  fi

  DB_NAME=$(basename "$ITEM")

  execute_ddls "$DB_NAME" "$ITEM"
done
