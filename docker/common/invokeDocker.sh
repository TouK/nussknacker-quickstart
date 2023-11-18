#!/bin/bash

set -ex

cd "$(dirname "$0")"

docker-compose --env-file "$BASE_PATH/.env" -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml $ADDITIONAL_COMPOSE_FILE "$@" 
