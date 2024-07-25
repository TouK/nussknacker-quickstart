#!/bin/bash -e

init_data_dir() {
  mkdir -p "$PG_DATA_DIR"
  chown postgres "$PG_DATA_DIR"
  /sbin/setuser postgres "$PG_BIN_DIR"/initdb -D "$PG_DATA_DIR"
}

init_custom_conf_dir() {
  mkdir -p "$PG_CUSTOM_CONF_DIR"
  chown postgres "$PG_CUSTOM_CONF_DIR"
}

configure_authentication() {
  cp "$PG_DATA_DIR/pg_hba.conf" "$PG_HBA_FILE"
  chown postgres "$PG_HBA_FILE"
  echo "#<Custom configuration>" >> "$PG_HBA_FILE"
  echo "host all all all md5" >> "$PG_HBA_FILE"
}

configure_pg_config() {
  cp "$PG_DATA_DIR/postgresql.conf" "$PG_CONF_FILE"
  chown postgres "$PG_CONF_FILE"
  echo "#<Custom configuration>" >> "$PG_CONF_FILE"
  echo "listen_addresses = '*'" >> "$PG_CONF_FILE"
}

init_bg_log_file() {
  touch /var/log/postgres_bg.log
  chown postgres /var/log/postgres_bg.log
}

wait_until_started() {
  local max_startup_timeout_in_s=10
  while ! pg_isready >/dev/null 2>&1; do
    sleep 1
    max_startup_timeout_in_s=$((max_startup_timeout_in_s - 1))
    if ((max_startup_timeout_in_s <= 0)); then
        echo "Postgres is not started"
        exit 1
    fi
  done
  echo "Postgres started"
}

create_custom_database() {
  echo "CREATE DATABASE \"$PG_DB_NAME\"" | execute_sql "" "postgres" ""
}

create_user() {
  echo "CREATE ROLE \"${PG_USER}\" WITH LOGIN PASSWORD '${PG_PASS}';" | execute_sql "" "postgres" ""
}

grant_privileges() {
    execute_sql "" "postgres" "" <<EOF
GRANT ALL PRIVILEGES ON DATABASE "${PG_DB_NAME}" TO "${PG_USER}";
ALTER DATABASE "${PG_DB_NAME}" OWNER TO "${PG_USER}";
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

start_bg() {
  /sbin/setuser postgres "$PG_BIN_DIR"/pg_ctl start -D "$PG_DATA_DIR" -l /var/log/postgres_bg.log
}

start() {
  /sbin/setuser postgres "$PG_BIN_DIR"/postgres -D "$PG_DATA_DIR" "--hba_file=$PG_HBA_FILE" "--config-file=$PG_CONF_FILE"
}

stop() {
  /sbin/setuser postgres "$PG_BIN_DIR"/pg_ctl stop -w -D "$PG_DATA_DIR"
}

"$@"
