#!/bin/bash -e

cd "$(dirname "$0")"

export BASE_PATH=$(pwd)


source ../../common/scripts/utils.sh

export ADDITIONAL_COMPOSE_FILE="-f $(fullPath ./docker-compose-streaming.yml)"

../common/invokeDocker.sh $@
