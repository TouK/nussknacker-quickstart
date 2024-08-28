#!/bin/bash -e

cd "$(dirname "$0")"

source ../lib.sh

if ! [ -v NU_DESIGNER_ADDRESS ] || [ -z "$NU_DESIGNER_ADDRESS" ]; then
  echo -e "${RED}ERROR: required variable NU_DESIGNER_ADDRESS not set or empty${RESET}\n"
  exit 1
fi

function reloadConfiguration() {
  set -e

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://${NU_DESIGNER_ADDRESS}/api/app/processingtype/reload"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
  local RESPONSE_BODY
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

  if [ "$HTTP_STATUS" != "204" ]; then
    echo -e "${RED}ERROR: Cannot reload Nu configuration.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY${RESET}\n"
    exit 22
  fi
}

echo -n "Reloading Nu configuration... "
reloadConfiguration
echo "OK"
