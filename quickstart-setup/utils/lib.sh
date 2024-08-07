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

function random_Ndigit_number() {
  if [ "$#" -ne 1 ]; then
    echo "Error: One parameter required: 1) number of digits"
    exit 1
  fi

  local LENGTH=$1
  local RESULT=""
  
  local FIRST_DIGIT=$((RANDOM % 9 + 1))
  RESULT+="$FIRST_DIGIT"
  
  while [ ${#RESULT} -lt $LENGTH ]; do
    local REMAINING=$((LENGTH - ${#RESULT}))
    local PART=$(printf "%05d" $((RANDOM % 100000)))
    RESULT+=${PART:0:$REMAINING}
  done
  echo "$RESULT"
}

function random_4digit_number() {
  random_Ndigit_number 4
}

function random_3digit_number() {
  random_Ndigit_number 3
}

function random_1digit_number() {
  random_Ndigit_number 1
}

function now() {
  echo "$(date +%s)$(random_3digit_number)"
}

function pick_randomly() {
  local OPTIONS=("$@") 
  local COUNT=${#OPTIONS[@]} 
  local RANDOM_INDEX=$((RANDOM % COUNT)) 
  echo "${OPTIONS[$RANDOM_INDEX]}"
}