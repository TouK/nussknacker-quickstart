#!/bin/bash -e

cd "$(dirname "$0")"

shopt -s nullglob

for FOLDER in /scenario-examples/*; do
    
  echo "Starting to configure and run example from $FOLDER directory ..."

  ./schema-registry/setup-schemas.sh "$FOLDER"
  ./kafka/setup-topics.sh "$FOLDER"
  ./nu/customize-nu-configuration.sh "$FOLDER"
  ./nu/import-and-deploy-example-scenarios.sh "$FOLDER"
  
done
