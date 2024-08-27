#!/bin/sh

set -e

echo "Starting Postgres service ..."

/app/mocks/db/postgres-init.sh

stop() {
  echo "Stopping Postgres service ..."
  /app/mocks/db/postgres-operations.sh stop
}

trap stop EXIT

exec /app/mocks/db/postgres-operations.sh start
