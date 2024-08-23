#!/bin/bash -e

cd "$(dirname "$0")"

function reloadConfiguration() {
  set -e

  local RESPONSE
  RESPONSE=$(curl -s -L -w "\n%{http_code}" -u admin:admin \
    -X POST "http://nginx:8080/api/app/processingtype/reload"
  )

  local HTTP_STATUS
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
  local RESPONSE_BODY
  RESPONSE_BODY=$(echo "$RESPONSE" | sed \$d)

  if [ "$HTTP_STATUS" != "204" ]; then
    echo -e "Error: Cannot reload Nu configuration.\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    exit 22
  fi
}

echo "Reloading Nu configuration ..."

reloadConfiguration

echo "Nu configuration reloaded!"
