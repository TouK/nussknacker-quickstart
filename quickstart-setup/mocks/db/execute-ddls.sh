#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

source postgres-operations.sh
source ../../utils/lib.sh


export PG_DB_NAME="mocks"
export PG_USER="mocks"
export PG_PASS="mocks_pass"

export PG_BIN_DIR="/usr/lib/postgresql/16/bin"
export PG_BASE_DIR="/home/postgres"
export PG_DATA_DIR="$PG_BASE_DIR/data"
export PG_CUSTOM_CONF_DIR="$PG_BASE_DIR/conf"
export PG_CONF_FILE="$PG_CUSTOM_CONF_DIR/postgresql.conf"
export PG_HBA_FILE="$PG_CUSTOM_CONF_DIR/pg_hba.conf"


SCENARIO_EXAMPLE_DIR_PATH=${1%/}

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

if [ -d "$SCENARIO_EXAMPLE_DIR_PATH/mocks/db" ]; then

  # start_bg
  wait_until_started 60
  # trap stop

  for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/mocks/db"/*; do
    if [ -f "$ITEM" ]; then
      continue
    fi

    DB_NAME=$(basename "$ITEM")

    execute_ddls "$DB_NAME" "$ITEM"

  done

fi
