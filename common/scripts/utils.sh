#!/bin/bash -e

fullPath() {
    local LOCATION=$1
    echo "$(cd "$(dirname "$LOCATION")"; pwd)/$(basename "$LOCATION")"
}