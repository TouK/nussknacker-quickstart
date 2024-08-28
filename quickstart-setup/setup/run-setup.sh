#!/bin/bash -e

cd "$(dirname "$0")"

source ../utils/lib.sh

shopt -s nullglob

for FOLDER in /scenario-examples/*; do
  if isScenarioEnabled "$FOLDER"; then
    echo -e "EXAMPLE SCENARIO $(basename "$FOLDER")\n"
    echo -e "Starting to configure and run example scenario from $FOLDER directory ...\n"

    ./schema-registry/setup-schemas.sh "$FOLDER"
    ./kafka/setup-topics.sh "$FOLDER"
    ./nu/customize-nu-configuration.sh "$FOLDER"
    ./nu/import-and-deploy-example-scenarios.sh "$FOLDER"
    
    echo -e "DONE!\n\n"
  else
    echo "Skipping configuring and running example scenario from $FOLDER directory."
  fi
done
