#!/bin/bash -e

cd "$(dirname "$0")"

source ../../utils/lib.sh

if [ "$#" -ne 1 ]; then
    echo -e "${RED}ERROR: One parameter required: 1) scenario example folder path${RESET}\n"
    exit 1
fi

SCENARIO_EXAMPLE_DIR_PATH=${1%/}
CONFS_DIR=/opt/nussknacker/conf
APP_CUSTOMIZATION_FILE_PATH="$CONFS_DIR/application-customizations.conf"

function customizeNuConfiguration() {
  if [ "$#" -ne 2 ]; then
    echo -e "${RED}ERROR: Two parameters required: 1) configuration file path 2) example scenario id${RESET}\n"
    exit 11
  fi

  set -e

  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH=$1
  local EXAMPLE_SCENARIO_ID=$2
  local EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME="${EXAMPLE_SCENARIO_ID}-$(basename "$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH")"

  echo -n "Including $EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH configuration... "

  cp -f "$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_PATH" "$CONFS_DIR/$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME"
  local INCLUDE_CONF_LINE="include \"$EXAMPLE_SCENARIO_RELATED_CONFIGURAION_FILE_NAME\""

  if ! grep -qxF "$INCLUDE_CONF_LINE" "$APP_CUSTOMIZATION_FILE_PATH"; then
    echo "$INCLUDE_CONF_LINE" >> "$APP_CUSTOMIZATION_FILE_PATH"
  fi
  echo "OK"
}

echo "Starting to customize Nu configuration..."

touch "$APP_CUSTOMIZATION_FILE_PATH"

shopt -s nullglob

for ITEM in "$SCENARIO_EXAMPLE_DIR_PATH/setup/nu-designer"/*; do
  if [ ! -f "$ITEM" ]; then
    continue
  fi

  if [[ ! "$ITEM" == *.conf ]]; then
    echo -e "${RED}ERROR: Unrecognized file $ITEM. Required file with extension '.conf' and content with HOCON Nu configuration${RESET}\n"
    exit 2
  fi

  SCENARIO_EXAMPLE_ID=$(basename "$SCENARIO_EXAMPLE_DIR_PATH")
  customizeNuConfiguration "$ITEM" "$SCENARIO_EXAMPLE_ID"
done

../../utils/nu/reload-configuration.sh

echo -e "Configuration customized!\n"