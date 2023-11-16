#!/bin/bash

set -ex

cd "$(dirname "$0")"

ls -la "/home/runner/work/nussknacker-quickstart/nussknacker-quickstart/docker/streaming"
ls -la "/home/runner/work/nussknacker-quickstart"

docker compose -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml --env-file="$BASE_PATH/.env" "$ADDITIONAL_COMPOSE_FILE" "$@" 
