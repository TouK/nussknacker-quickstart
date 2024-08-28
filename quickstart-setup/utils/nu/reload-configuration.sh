#!/bin/bash -e

cd "$(dirname "$0")"

if ! [ -v NU_DESIGNER_ADDRESS ] || [ -z "$NU_DESIGNER_ADDRESS" ]; then
  echo "ERROR: required variable NU_DESIGNER_ADDRESS not set or empty"
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
    echo -e "ERROR: Cannot reload Nu configuration.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 22
  fi
}

echo "Reloading Nu configuration ..."

reloadConfiguration

echo "Nu configuration reloaded!"
