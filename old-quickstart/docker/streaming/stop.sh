#!/bin/bash -e

cd "$(dirname "$0")"

export BASE_PATH=$(pwd)

displayLogs() {
    ../common/displayAllDockerLogs.sh 
}

trap displayLogs ERR

source ../../common/scripts/utils.sh

export ADDITIONAL_COMPOSE_FILE="-f $(fullPath ./docker-compose-streaming.yml)"

../common/invokeDocker.sh stop
