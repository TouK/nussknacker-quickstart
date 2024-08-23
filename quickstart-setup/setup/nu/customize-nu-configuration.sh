#!/bin/bash -ex

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) scenario example folder path"
    exit 1
fi

SCENARIO_EXAMPLE_DIR_PATH=$1
CONFS_DIR=/opt/nussknacker/conf
APP_CUSTOMIZATION_FILE_PATH="$CONFS_DIR/application-customizations.conf"

function customizeNuConfiguration() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) configuration file path"
    exit 11
  fi

  set -e

  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH=$1
  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME=$(basename "$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH")

  echo "Including $EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH configuration"

  cp -f "$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH" "$CONFS_DIR"
  local INCLUDE_CONF_LINE="include \"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME\""

  if ! grep -qxF "$INCLUDE_CONF_LINE" "$APP_CUSTOMIZATION_FILE_PATH"; then
    echo "$INCLUDE_CONF_LINE" >> "$APP_CUSTOMIZATION_FILE_PATH"
  fi
}

echo "Starting to customize Nu configuration ..."

touch "$APP_CUSTOMIZATION_FILE_PATH"

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH"/nu-designer/*; do
  if [ ! -f "$ITEM" ]; then
    echo "Unrecognized file $ITEM. Required file with extension '.conf' and content with HOCON Nu configuration"
    exit 2
  fi

  if [[ ! "$ITEM" == *.conf ]]; then
    echo "Unrecognized file $ITEM. Required file with extension '.conf' and content with HOCON Nu configuration"
    exit 3
  fi

  customizeNuConfiguration "$ITEM"
done

../../utils/nu/reload-configuration.sh

echo -e "DONE!\n\n"