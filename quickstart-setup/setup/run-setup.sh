#!/bin/bash -e

cd "$(dirname "$0")"

shopt -s nullglob

for FOLDER in /scenario-examples/*; do
    
  echo -e "EXAMPLE SCENARIO $(basename "$FOLDER")\n"
  echo -e "Starting to configure and run example from $FOLDER directory ...\n"

  ./schema-registry/setup-schemas.sh "$FOLDER"
  ./kafka/setup-topics.sh "$FOLDER"
  ./nu/customize-nu-configuration.sh "$FOLDER"
  ./nu/import-and-deploy-example-scenarios.sh "$FOLDER"
  
  echo -e "DONE!\n\n"
  
done
