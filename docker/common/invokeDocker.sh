#!/bin/bash -ex

if ! command -v "docker-compose" &> /dev/null; then
    echo "docker-compose does not exist. Please install it first https://docs.docker.com/compose/install/"
    exit 1
fi

cd "$(dirname "$0")"

docker-compose --env-file "$BASE_PATH/.env" -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml $ADDITIONAL_COMPOSE_FILE "$@" 
