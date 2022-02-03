#!/bin/bash

set -e
cd "$(dirname $0)"

./testQuickstart.sh `realpath ../../k8s-helm/scenarios/DetectLargeTransactionsLite.json`
