#!/bin/bash -e

cd "$(dirname "$0")"

source postgres-operations.sh

echo "Starting Postgres service..."

./postgres-init.sh

stop() {
  echo "Stopping Postgres service..."
  postgres_stop
}

trap stop EXIT

postgres_start
