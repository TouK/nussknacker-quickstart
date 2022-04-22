#!/bin/bash

set -e
cd "$(dirname $0)"

./testQuickstart.sh `realpath ../../docker/streaming/scenarios/DetectLargeTransactions.json`