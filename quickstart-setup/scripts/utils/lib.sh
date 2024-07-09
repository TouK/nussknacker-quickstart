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

function random_4digit_number() {
  od -An -t d -N 2 /dev/urandom |  head -n 1 | tr -d ' ' | head -c 4
}

function random_3digit_number() {
  random_4digit_number | head -c 3
}

function now() {
  echo "$(date +%s)$(random_3digit_number)"
}

function pick_randomly() {
  local options=("$@") 
  local count=${#options[@]} 
  local random_index=$((RANDOM % count)) 
  echo "${options[$random_index]}"
}