#!/bin/bash -e

DOCKER_COMPOSE_COMMAND=""
if command -v docker &>/dev/null && docker compose version &>/dev/null; then
    DOCKER_COMPOSE_COMMAND="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_COMMAND="docker-compose"
else
  echo "Docker Compose does not exist. Please install it first https://docs.docker.com/compose/install/"
  exit 1
fi

cd "$(dirname "$0")"

$DOCKER_COMPOSE_COMMAND --env-file "$BASE_PATH/.env" -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml $ADDITIONAL_COMPOSE_FILE "$@"
