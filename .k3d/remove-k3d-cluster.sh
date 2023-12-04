#!/bin/bash -e

if ! command -v "k3d" &> /dev/null; then
    echo "k3d does not exist. Please install it first https://k3d.io/"
    exit 1
fi

cd "$(dirname "$0")"

k3d cluster delete nu-quickstart-cluster