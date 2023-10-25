#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

ls -la
echo "READLINK: $(readlink -f ./docker-compose-streaming.yml)"
echo "CUSTOM: $(cd "$(dirname "./docker-compose-streaming.yml")"; pwd)/$(basename "./docker-compose-streaming.yml")"

export BASE_PATH=$(pwd)
export ADDITIONAL_COMPOSE_FILE="-f $(readlink -f ./docker-compose-streaming.yml)"

[[ "$NO_PULL" == "true" ]] || ../common/invokeDocker.sh pull
../common/invokeDocker.sh up -d

cat << EOF
----------------------------------------------------------------------------------

Nussknaker will be available at http://localhost:8081 (credentials: admin:admin) ...

----------------------------------------------------------------------------------
EOF