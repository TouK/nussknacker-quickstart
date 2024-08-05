#!/bin/sh

"$PG_CUSTOM_BIN_DIR"/init_ddls.sh
exec "$PG_CUSTOM_BIN_DIR"/postgres_operations.sh start
