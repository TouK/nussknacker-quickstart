#!/bin/bash -e

fullPath() {
    local LOCATION=$1
    echo "$(cd "$(dirname "$LOCATION")"; pwd)/$(basename "$LOCATION")"
}

sha256() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        shasum -a 256
    else
        sha256sum
    fi
}