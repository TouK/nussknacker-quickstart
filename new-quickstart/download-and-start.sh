#!/usr/bin/env bash
set -e

BRANCH_NAME="NU-1726"
ZIP_NAME="$BRANCH_NAME.zip"

wget "https://github.com/TouK/nussknacker-quickstart/archive/refs/heads/feature/$ZIP_NAME"
rm -rf "$BRANCH_NAME"
unzip "$ZIP_NAME"    
cd "$BRANCH_NAME"
./start.sh