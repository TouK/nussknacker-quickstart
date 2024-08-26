#!/bin/bash -e

cd "$(dirname "$0")"

for FOLDER in /scenario-examples/*/; do
    
  echo "Starting to configure mocks for scenario from $FOLDER directory ..."

  ./db/execute-ddls.sh "$FOLDER"
  ./http-service/configure-mock-http-services.sh "$FOLDER"

done
