#!/bin/bash -ex

JQ_LINUX_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
JQ_MAC_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"

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

local_jq() {
    set -x
    local UTILS_DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
  
    if ! command -v "$UTILS_DIR/jq" &> /dev/null; then
        echo "jq is not installed. Downloading and installing jq..."

        # Determine the system type (Linux or macOS)
        if [[ "$(uname)" == "Linux" ]]; then
            JQ_URL=$JQ_LINUX_URL
        elif [[ "$(uname)" == "Darwin" ]]; then
            JQ_URL=$JQ_MAC_URL
        else
            echo "Unsupported operating system. Please install jq manually."
            exit 1
        fi

        # Download jq binary
        curl -L "$JQ_URL" -o "$UTILS_DIR/jq"
        chmod +x "$UTILS_DIR/jq"
    fi

    "$UTILS_DIR"/jq $@
}