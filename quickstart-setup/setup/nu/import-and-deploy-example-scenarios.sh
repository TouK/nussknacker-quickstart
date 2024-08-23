#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

SCENARIO_EXAMPLE_DIR_PATH=${1%/}

function importAndDeployScenario() {
  if [ "$#" -ne 2 ]; then
    echo "Error: Two parameters required: 1) scenario name, 2) example scenario file path"
    exit 11
  fi

  set -e

  local EXAMPLE_SCENARIO_NAME=$1
  local EXAMPLE_SCENARIO_FILE=$2

  ../../utils/nu/load-scenario-from-json-file.sh "$EXAMPLE_SCENARIO_NAME" "$EXAMPLE_SCENARIO_FILE"
  ../../utils/nu/deploy-scenario-and-wait-for-running-state.sh "$EXAMPLE_SCENARIO_NAME"
}

echo "Starting to import and deploy example scenarios ..."

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.json ]]; then
    echo "Unrecognized file $ITEM. Required file with extension '.json' and content with Nu scenario JSON"
    exit 2
  fi

  EXAMPLE_SCENARIO_NAME="$(basename "$ITEM" ".json")"

  importAndDeployScenario "$EXAMPLE_SCENARIO_NAME" "$ITEM"
done

echo -e "DONE!\n\n"
