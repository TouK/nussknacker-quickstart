#!/bin/bash -e

cd "$(dirname "$0")"

function customizeNuConfiguration() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) configuration file name"
    exit 11
  fi

  set -e

  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME=$1

  cp -f "$(realpath configuration/"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME")" "$CONFS_DIR"
  local INCLUDE_CONF_LINE="include \"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME\""

  if ! grep -qxF "$INCLUDE_CONF_LINE" "$APP_CUSTOMIZATION_FILE_PATH"; then
    echo "$INCLUDE_CONF_LINE" >> "$APP_CUSTOMIZATION_FILE_PATH"
  fi
}

echo "Starting to customize Nu configuration ..."

CONFS_DIR=/opt/nussknacker/conf
APP_CUSTOMIZATION_FILE_PATH="$CONFS_DIR/application-customization.conf"

touch "$APP_CUSTOMIZATION_FILE_PATH"

while IFS= read -r EXAMPLE_SCENARIO_FILENAME; do

  if [[ $EXAMPLE_SCENARIO_FILENAME == "#"* ]]; then
    continue
  fi

  customizeNuConfiguration "$(basename "$EXAMPLE_SCENARIO_FILENAME" ".conf")"
  
done < "example-scenarios.txt"

../../utils/nu/reload-configuration.sh

echo -e "DONE!\n\n"