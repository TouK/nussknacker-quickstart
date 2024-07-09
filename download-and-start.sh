#!/usr/bin/env bash
set -e

BRANCH_NAME="main"
NU_QUICKSTART_DIR="nussknacker-quickstart-$BRANCH_NAME"

wget -O "$NU_QUICKSTART_DIR.zip" "https://github.com/TouK/nussknacker-quickstart/archive/refs/heads/$BRANCH_NAME.zip"
rm -rf "$NU_QUICKSTART_DIR"
unzip -q "$NU_QUICKSTART_DIR.zip" 
cd "$NU_QUICKSTART_DIR"
./start.sh