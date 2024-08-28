#!/bin/bash -e

cd "$(dirname "$0")"

source ../utils/lib.sh

shopt -s nullglob

echo -e "${MAGENTA}-------- SETUP STAGE is starting... -------${RESET}\n"

for FOLDER in /scenario-examples/*; do
  if isScenarioEnabled "$FOLDER"; then
    echo -e "Starting to configure and run example scenarios from ${GREEN}$FOLDER${RESET} directory...\n\n"

    ./schema-registry/setup-schemas.sh "$FOLDER"
    ./kafka/setup-topics.sh "$FOLDER"
    ./nu/customize-nu-configuration.sh "$FOLDER"
    ./nu/import-and-deploy-example-scenarios.sh "$FOLDER"
    
    echo -e "Scenarios from ${GREEN}$FOLDER${RESET} directory configured and running!\n\n"
  else
    echo "Skipping configuring and running example scenario from ${GREEN}$FOLDER${RESET} directory."
  fi
done

echo -e "${MAGENTA}-------- SETUP STAGE is finished! ---------${RESET}\n\n"
