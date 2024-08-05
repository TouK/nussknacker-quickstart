#!/bin/bash -e

script_dir=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=/dev/null
. "${script_dir}"/postgres_operations.sh
# shellcheck source=/dev/null
. "${script_dir}"/common.sh

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

run_startup_scripts() {
  startup_scripts_executed_file="$PG_BASE_DIR/startup_scripts_executed"
  if [ ! -f "$startup_scripts_executed_file" ]; then
    start_bg
    execute_ddls
    stop
    touch "$startup_scripts_executed_file"
  fi
}

run_startup_scripts
