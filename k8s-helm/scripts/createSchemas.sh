#!/bin/bash
set -e

cd "$(dirname $0)"
./setEnv.sh

../../common/schemas/createSchemas.sh $@