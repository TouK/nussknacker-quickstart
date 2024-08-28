#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if [ "$#" -ne 2 ]; then
    echo -e "${RED}ERROR: Two parameters required: 1) OpenAPI service slug, 2) request generator script path${RESET}\n"
    exit 1
fi

OPENAPI_SERVICE_SLUG=$1
REQUEST_GENERATOR_SCRIPT=$2

verifyBashScript "$REQUEST_GENERATOR_SCRIPT"

while true; do
  sleep 0.1
  ./send-request-to-nu-openapi-service.sh "$OPENAPI_SERVICE_SLUG" "$($REQUEST_GENERATOR_SCRIPT)" > /dev/null || true
done
