#!/bin/bash -e

cd "$(dirname "$0")"

source ../utils/lib.sh

shopt -s nullglob

magenta_echo "-------- SETUP STAGE is starting... -------\n"

for FOLDER in /scenario-examples/*; do
  if is_scenario_enabled "$FOLDER"; then
    echo -e "Starting to configure and run example scenarios from ${GREEN}$FOLDER directory...\n\n"

    ./schema-registry/setup-schemas.sh "$FOLDER"
    ./kafka/setup-topics.sh "$FOLDER"
    ./nu/customize-nu-configuration.sh "$FOLDER"
    ./nu/import-and-deploy-example-scenarios.sh "$FOLDER"
    
    echo -e "Scenarios from ${GREEN}$FOLDER directory configured and running!\n\n"
  else
    echo "Skipping configuring and running example scenario from ${GREEN}$FOLDER directory."
  fi
done

magenta_echo "-------- SETUP STAGE is finished! ---------\n\n"
