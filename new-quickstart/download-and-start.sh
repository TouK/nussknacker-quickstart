#!/usr/bin/env bash
set -e

BRANCH_NAME="feature/NU-1726"
NU_QUICKSTART_DIR="nussknacker-quickstart"

wget -O "$NU_QUICKSTART_DIR.zip" "https://github.com/TouK/nussknacker-quickstart/archive/refs/heads/$BRANCH_NAME.zip"
rm -rf "$NU_QUICKSTART_DIR"
unzip "$NU_QUICKSTART_DIR.zip"    
cd "$NU_QUICKSTART_DIR/new-quickstart"
./start.sh