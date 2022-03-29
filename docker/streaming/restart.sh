#!/usr/bin/env bash

set -e

cd "$(dirname $0)"
export BASE_PATH=`pwd`
export ADDITIONAL_COMPOSE_FILE="-f $(realpath ./docker-compose-streaming.yml)"

../common/restartDocker.sh