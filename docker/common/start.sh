#!/usr/bin/env bash

set -e

cd "$(dirname $0)"
export BASE_PATH=`pwd`

[[ "$NO_PULL" == "true" ]] || ./invokeDocker.sh pull
./invokeDocker.sh up -d
