#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

docker-compose -f docker-compose.yml -f docker-compose-env.yml -f docker-compose-custom.yml up -d
