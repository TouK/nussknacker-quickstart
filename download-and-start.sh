#!/usr/bin/env bash
set -e

BRANCH_NAME=${1:-main}
NU_QUICKSTART_DIR="nussknacker-quickstart-$BRANCH_NAME"

curl -L -o "$NU_QUICKSTART_DIR.zip" "https://github.com/TouK/nussknacker-quickstart/archive/refs/heads/$BRANCH_NAME.zip"
rm -rf "$NU_QUICKSTART_DIR"
unzip -q "$NU_QUICKSTART_DIR.zip" 
cd "$NU_QUICKSTART_DIR"

./start.sh