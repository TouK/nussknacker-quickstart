#!/bin/bash

set -e
cd "$(dirname $0)"

./testQuickstart.sh `realpath ../../docker/scenarios/DetectLargeTransactions.json`