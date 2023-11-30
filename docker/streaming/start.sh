#!/bin/bash -e

cd "$(dirname "$0")"

source ../../common/scripts/utils.sh

export BASE_PATH=$(pwd)
export ADDITIONAL_COMPOSE_FILE="-f $(fullPath ./docker-compose-streaming.yml)"

[[ "$NO_PULL" == "true" ]] || ../common/invokeDocker.sh pull
../common/invokeDocker.sh up -d

cat << EOF
----------------------------------------------------------------------------------

Nussknaker will be available at http://localhost:8081 (credentials: admin:admin) ...

----------------------------------------------------------------------------------
EOF