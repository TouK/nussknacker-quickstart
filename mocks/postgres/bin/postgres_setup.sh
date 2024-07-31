#!/bin/bash -e

script_dir=$(dirname "${BASH_SOURCE[0]}")
# shellcheck source=/dev/null
. "${script_dir}"/postgres_operations.sh
# shellcheck source=/dev/null
. "${script_dir}"/common.sh

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

execute_ddls() {
  local schema_name
  local ddl_content
  for file in "$PG_DDL_DIR"/*; do
      if [ -f "$file" ]; then
          schema_name=$(basename "$(strip_extension "$file")")
          echo "Creating schema: $schema_name"
          create_schema "$PG_USER" "$schema_name"
          ddl_content=$(wrap_sql_with_current_schema "$schema_name" "$(cat "$file")")
          echo "Executing ddl: $file with content: $ddl_content"
          echo "$ddl_content" | execute_sql "" "$PG_USER" "$PG_PASS"
      fi
  done
}

init_db
start_bg
wait_until_started
configure_users
execute_ddls
stop
