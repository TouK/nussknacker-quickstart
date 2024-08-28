#!/bin/bash -e

cd "$(dirname "$0")"

shopt -s nullglob

for FOLDER in /scenario-examples/*; do
  if [ ! -f "$FOLDER/disabled" ]; then
    echo "Starting to configure mocks for scenario from $FOLDER directory ..."

    ./db/execute-ddls.sh "$FOLDER"
    ./http-service/configure-mock-http-services.sh "$FOLDER"

    echo -e "DONE!\n\n"
  else
    echo "Skipping configuring mocks for scenario from $FOLDER directory."
  fi
done
