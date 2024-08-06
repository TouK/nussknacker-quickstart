#!/bin/bash -e

strip_extension() {
  local file="$1"
  echo "${file%.*}"
}
