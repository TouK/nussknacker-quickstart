#!/bin/sh

set -e
set -x

export PG_DB_NAME="mocks"
export PG_USER="mocks"
export PG_PASS="mocks_pass"

export PG_BIN_DIR="/usr/lib/postgresql/16/bin"
export PG_BASE_DIR="/home/postgres"
export PG_DATA_DIR="$PG_BASE_DIR/data"
export PG_CUSTOM_CONF_DIR="$PG_BASE_DIR/conf"
export PG_CONF_FILE="$PG_CUSTOM_CONF_DIR/postgresql.conf"
export PG_HBA_FILE="$PG_CUSTOM_CONF_DIR/pg_hba.conf"

/app/mocks/db/scripts/postgres-init.sh
exec /app/mocks/db/scripts/postgres-operations.sh start
