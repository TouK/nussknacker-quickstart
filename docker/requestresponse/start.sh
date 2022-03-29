#!/usr/bin/env bash

set -e

cd "$(dirname $0)"
export BASE_PATH=`pwd`

../common/invokeDocker.sh pull 
../common/invokeDocker.sh up -d
