#!/bin/bash -e

cd "$(dirname "$0")"

# shellcheck source=/dev/null
. postgres_operations.sh

init_db() {
  echo "Initiation of Postgres DB ..."
  init_bg_log_file
  init_data_dir
  init_custom_conf_dir
  configure_pg_config
  configure_authentication
}

configure_users() {
  echo "Configuring Postgres users ..."
  start_bg
  wait_until_started
  create_user
  create_custom_database
  grant_privileges
  alter_pg_user_pass
  stop
}

if ! is_db_initialized; then
  init_db
  configure_users
fi
