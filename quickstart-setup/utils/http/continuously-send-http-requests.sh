#!/bin/bash -e

if [ "$#" -ne 2 ]; then
    echo "ERROR: Two parameters required: 1) OpenAPI service slug, 2) request generator script path"
    exit 1
fi

cd "$(dirname "$0")"

source ../lib.sh

OPENAPI_SERVICE_SLUG=$1
REQUEST_GENERATOR_SCRIPT=$2

verifyBashScript "$REQUEST_GENERATOR_SCRIPT"

while true; do
  sleep 0.1
  ./send-request-to-nu-openapi-service.sh "$OPENAPI_SERVICE_SLUG" "$($REQUEST_GENERATOR_SCRIPT)" > /dev/null || true
done
