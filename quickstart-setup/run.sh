#!/bin/bash -e

cd "$(dirname "$0")"

rm -rf /app/healthy

if /app/mocks/db/is-postgres-ready.sh && /app/mocks/http-service/is-wiremock-ready.sh; then
  echo -e "\nStarting to setup Nu stack ..."
  
  /app/mocks/configure.sh
  /app/setup/run-setup.sh
  /app/data/keep-sending.sh
  
  echo "Setup done!"
  
  touch /app/healthy
  
  # loop forever (you can use manually called utils scripts now)
  tail -f /dev/null
else
  echo "Waiting for Postgres and Wiremock to be up and ready ..."
  sleep 5
  exit 1
fi
