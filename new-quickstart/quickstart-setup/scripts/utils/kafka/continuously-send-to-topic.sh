#!/bin/bash -ex

if [ "$#" -ne 2 ]; then
    echo "Two parameters required: 1) topic name, 2) generator script path"
    exit 1
fi

cd "$(dirname "$0")"

function verifyBashScript() {
  local FILE=$1

  if [[ -f "$FILE" ]]; then
    if [[ $(head -n 1 "$FILE") =~ ^#!/bin/bash ]]; then
      return 0
    else
      echo "$FILE exists but is not a Bash script."
      return 1
    fi
  else
    echo "$FILE does not exist."
    return 2
  fi
}

TOPIC=$1
GENERATOR_SCRIPT=$2

verifyBashScript "$GENERATOR_SCRIPT"

while true; do
  sleep 0.1
  ./send-to-topic.sh "$TOPIC" "$($GENERATOR_SCRIPT)"
done
