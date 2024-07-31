#!/bin/sh -e

cd "$(dirname "$0")"

export PG_DB_NAME="mocks"
export PG_USER="mocks"
export PG_PASS="mocks_pass"
export PG_BIN_DIR="/usr/lib/postgresql/16/bin"
export PG_DIR="/usr/local/pgsql"
export PG_DATA_DIR="$PG_DIR/data"
export PG_CUSTOM_BIN_DIR="$PG_DIR/bin"
export PG_CUSTOM_CONF_DIR="$PG_DIR/conf"
export PG_CONF_FILE="$PG_CUSTOM_CONF_DIR/postgresql.conf"
export PG_HBA_FILE="$PG_CUSTOM_CONF_DIR/pg_hba.conf"

./postgres_setup.sh

exec ./postgres_operations.sh start
