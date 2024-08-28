#!/bin/bash -e

cd "$(dirname "$0")"

source /app/utils/lib.sh

rm -rf /app/healthy

if /app/mocks/db/is-postgres-ready.sh && /app/mocks/http-service/is-wiremock-ready.sh; then
  echo -e "\n${GREEN}------ Nu scenarios library is being prepared... ---------${RESET}\n\n"
  
  /app/mocks/configure.sh
  /app/setup/run-setup.sh
  /app/data/keep-sending.sh
  
  echo -e "\n${GREEN}------ Nu scenarios library sucessfully bootstrapped! ----${RESET}\n\n"
  
  touch /app/healthy
  
  # loop forever (you can use manually called utils scripts now)
  tail -f /dev/null
else
  echo -e "\nWaiting for Postgres and Wiremock to be up and ready...\n"
  sleep 5
  exit 1
fi
