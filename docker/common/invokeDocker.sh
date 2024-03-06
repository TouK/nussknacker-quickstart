#!/bin/bash -e

DOCKER_COMPOSE_COMMAND="docker compose"

if command -v "docker-compose" &> /dev/null; then
  DOCKER_COMPOSE_COMMAND="docker-compose"
eleif ! command -v "$DOCKER_COMPOSE_COMMAND" &> /dev/null;
  echo "docker-compose does not exist. Please install it first https://docs.docker.com/compose/install/"
  exit 1
fi

cd "$(dirname "$0")"

$DOCKER_COMPOSE_COMMAND --env-file "$BASE_PATH/.env" -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml $ADDITIONAL_COMPOSE_FILE "$@"
