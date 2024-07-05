#!/bin/bash -e

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