#!/bin/bash -e

PG_DB_NAME="mocks"
PG_USER="mocks"
PG_PASS="mocks_pass"

PG_BIN_DIR="/usr/lib/postgresql/16/bin"
PG_BASE_DIR="/home/postgres"
PG_DATA_DIR="$PG_BASE_DIR/data"
PG_CUSTOM_CONF_DIR="$PG_BASE_DIR/conf"
PG_CONF_FILE="$PG_CUSTOM_CONF_DIR/postgresql.conf"
PG_HBA_FILE="$PG_CUSTOM_CONF_DIR/pg_hba.conf"

source /app/utils/lib.sh

init_data_dir() {
  if [ ! -e "$PG_DATA_DIR" ]; then
    mkdir -p "$PG_DATA_DIR"
    chown postgres "$PG_DATA_DIR"
    /sbin/setuser postgres "$PG_BIN_DIR"/initdb -D "$PG_DATA_DIR"
  fi
}

init_custom_conf_dir() {
  if [ ! -e "$PG_CUSTOM_CONF_DIR" ]; then
    mkdir -p "$PG_CUSTOM_CONF_DIR"
    chown postgres "$PG_CUSTOM_CONF_DIR"
  fi
}

configure_authentication() {
  if [ ! -f "$PG_HBA_FILE" ]; then
    cp "$PG_DATA_DIR/pg_hba.conf" "$PG_HBA_FILE"
    chown postgres "$PG_HBA_FILE"
    echo "#<Custom configuration>" >> "$PG_HBA_FILE"
    echo "host all all all md5" >> "$PG_HBA_FILE"
  fi
}

configure_pg_config() {
  if [ ! -f "$PG_CONF_FILE" ]; then
    cp "$PG_DATA_DIR/postgresql.conf" "$PG_CONF_FILE"
    chown postgres "$PG_CONF_FILE"
    echo "#<Custom configuration>" >> "$PG_CONF_FILE"
    echo "listen_addresses = '*'" >> "$PG_CONF_FILE"
  fi
}

init_bg_log_file() {
  local log_file
  log_file="/var/log/postgres_bg.log"
  if [ ! -f "$log_file" ]; then
    touch "$log_file"
    chown postgres "$log_file"
  fi
}

wait_until_started() {
  local max_startup_timeout_in_s=${1:-10}
  while ! pg_isready >/dev/null 2>&1; do
    sleep 1
    max_startup_timeout_in_s=$((max_startup_timeout_in_s - 1))
    if ((max_startup_timeout_in_s <= 0)); then
        echo -e "${RED}ERROR: Postgres is not started${RESET}\n"
        exit 1
    fi
  done
  echo "Postgres started"
}

create_custom_database() {
  local db_name="${1:-$PG_DB_NAME}"
  DB_EXISTS=$(echo "SELECT 1 FROM pg_database WHERE datname='$db_name'" | execute_sql "" "postgres" "" "-tA")
  if [ "$DB_EXISTS" != "1" ]; then
    echo "CREATE DATABASE \"$db_name\"" | execute_sql "" "postgres" ""
  else
    echo "DB already exists - creation skipped"
  fi
}

create_user() {
  ROLE_EXISTS=$(echo "SELECT 1 FROM pg_roles WHERE rolname='$PG_USER'" | execute_sql "" "postgres" "" "-tA")
  if [ "$ROLE_EXISTS" != "1" ]; then
    echo "CREATE ROLE \"${PG_USER}\" WITH LOGIN PASSWORD '${PG_PASS}';" | execute_sql "" "postgres" ""
  else
    echo "ROLE already exists - creation skipped"
  fi
}

grant_privileges() {
  local user="${1:-$PG_USER}"
  local db_name="${2:-$PG_DB_NAME}"
    execute_sql "" "postgres" "" <<EOF
GRANT ALL PRIVILEGES ON DATABASE "${db_name}" TO "${user}";
ALTER DATABASE "${db_name}" OWNER TO "${user}";
EOF
}

create_schema() {
  local user="${1:-$PG_USER}"
  local schema_name="${2:-PUBLIC}"
  echo "CREATE SCHEMA IF NOT EXISTS \"$schema_name\" AUTHORIZATION \"$user\"" | execute_sql "$PG_DB_NAME" "postgres" ""
}

wrap_sql_with_current_schema() {
  local schema_name="${1:-PUBLIC}"
  local sql="$2"
  cat <<EOF
SET search_path TO $schema_name;
$sql
RESET search_path;
EOF
}

alter_pg_user_pass() {
  echo "ALTER ROLE postgres WITH PASSWORD 'postgres';" | execute_sql "" "postgres" ""
}

execute_sql() {
  local -r db="${1:-}"
  local -r user="${2:-postgres}"
  local -r pass="${3:-}"
  local opts
  read -r -a opts <<<"${@:4}"
  local args=("-U" "$user" "-p" "${PG_PORT:-5432}" "-h" "127.0.0.1")
  [[ -n "$db" ]] && args+=("-d" "$db")
  [[ "${#opts[@]}" -gt 0 ]] && args+=("${opts[@]}")
  PGPASSWORD=$pass psql "${args[@]}"
}

postgres_start_bg() {
  /sbin/setuser postgres "$PG_BIN_DIR"/pg_ctl start -D "$PG_DATA_DIR" -l /var/log/postgres_bg.log
}

postgres_start() {
  /sbin/setuser postgres "$PG_BIN_DIR"/postgres -D "$PG_DATA_DIR" "--hba_file=$PG_HBA_FILE" "--config-file=$PG_CONF_FILE"
}

postgres_stop() {
  /sbin/setuser postgres "$PG_BIN_DIR"/pg_ctl stop -w -D "$PG_DATA_DIR"
}