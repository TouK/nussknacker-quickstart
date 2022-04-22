#!/bin/bash

set -e
cd "$(dirname $0)"
set -a; . ../.env; set +a

../../common/schemas/createSchemas.sh $@