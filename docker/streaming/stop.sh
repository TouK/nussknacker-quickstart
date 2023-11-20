#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

source ../../common/scripts/utils.sh

export BASE_PATH=$(pwd)
export ADDITIONAL_COMPOSE_FILE="-f $(fullPath ./docker-compose-streaming.yml)"

../common/invokeDocker.sh stop
