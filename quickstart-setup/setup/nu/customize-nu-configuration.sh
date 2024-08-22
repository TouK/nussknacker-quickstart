#!/bin/bash -e

cd "$(dirname "$0")"

function customizeNuConfiguration() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) configuration file name"
    exit 11
  fi

  set -e

  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME=$1

  echo "Including $EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME configuration"

  cp -f "$(realpath configurations/"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME")" "$CONFS_DIR"
  local INCLUDE_CONF_LINE="include \"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME\""

  if ! grep -qxF "$INCLUDE_CONF_LINE" "$APP_CUSTOMIZATION_FILE_PATH"; then
    echo "$INCLUDE_CONF_LINE" >> "$APP_CUSTOMIZATION_FILE_PATH"
  fi
}

echo "Starting to customize Nu configuration ..."

CONFS_DIR=/opt/nussknacker/conf
APP_CUSTOMIZATION_FILE_PATH="$CONFS_DIR/application-customizations.conf"

touch "$APP_CUSTOMIZATION_FILE_PATH"

while IFS= read -r EXAMPLE_SCENARIO_FILENAME; do

  if [[ $EXAMPLE_SCENARIO_FILENAME == "#"* ]]; then
    continue
  fi

  EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME="$(basename "$EXAMPLE_SCENARIO_FILENAME" ".json")-related.conf"

  if [ -e "configurations/$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME" ]; then
    customizeNuConfiguration "$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME"
  fi
  
done < "example-scenarios.txt"

../../utils/nu/reload-configuration.sh

echo -e "DONE!\n\n"