#!/usr/bin/env bash

set -e

cd "$(dirname $0)"
export BASE_PATH=`pwd`

../invokeDocker.sh pull 
../invokeDocker.sh up -d
