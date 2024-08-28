#!/bin/bash -e

cd "$(dirname "$0")"

source ../utils/lib.sh

shopt -s nullglob

echo -e "${MAGENTA}-------- MOCK CONFIGURATION STAGE is starting... ----${RESET}\n"

for FOLDER in /scenario-examples/*; do
  if isScenarioEnabled "$SCENARIO_DIR"; then
    echo -e "Starting to configure mocks for scenarios from ${GREEN}$FOLDER${RESET} directory...\n\n"

    ./db/execute-ddls.sh "$FOLDER"
    ./http-service/configure-mock-http-services.sh "$FOLDER"

    echo -e "Mocks for scenarios from ${GREEN}$FOLDER${RESET} directory configured!\n\n"
  else
    echo "Skipping configuring mocks for scenario from ${GREEN}$FOLDER${RESET} directory."
  fi
done

echo -e "${MAGENTA}-------- MOCK CONFIGURATION STAGE is finished! ------${RESET}\n\n"