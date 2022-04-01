#!/bin/bash
unset RELEASE
set -e

cd "$(dirname $0)"
../../../common/schemas/createSchemas.sh $@