#!/bin/bash -e

script_dir=$(dirname "${BASH_SOURCE[0]}")
# shellcheck source=/dev/null
. "${script_dir}"/postgres_operations.sh

init_db() {
  init_bg_log_file
  init_data_dir
  init_custom_conf_dir
  configure_pg_config
  configure_authentication
}

configure_users() {
  create_user
  create_custom_database
  grant_privileges
  alter_pg_user_pass
}

init_db
start_bg
wait_until_started
configure_users
stop
