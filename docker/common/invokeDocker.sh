#!/bin/bash

set -e

cd "$(dirname $0)"
docker compose -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml --env-file=${BASE_PATH}/.env $ADDITIONAL_COMPOSE_FILE $@ 
