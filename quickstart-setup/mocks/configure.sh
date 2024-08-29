#!/bin/bash -e

cd "$(dirname "$0")"

source ../utils/lib.sh

shopt -s nullglob

magenta_echo "-------- MOCK CONFIGURATION STAGE is starting... ----\n"

for FOLDER in /scenario-examples/*; do
  if is_scenario_enabled "$SCENARIO_DIR"; then
    echo -e "Starting to configure mocks for scenarios from ${GREEN}$FOLDER directory...\n\n"

    ./db/execute-ddls.sh "$FOLDER"
    ./http-service/configure-mock-http-services.sh "$FOLDER"

    echo -e "Mocks for scenarios from ${GREEN}$FOLDER directory configured!\n\n"
  else
    echo "Skipping configuring mocks for scenario from ${GREEN}$FOLDER directory."
  fi
done

magenta_echo "-------- MOCK CONFIGURATION STAGE is finished! ------\n\n"