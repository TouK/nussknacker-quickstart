#!/bin/bash

set -e
cd "$(dirname $0)"
set -a; . ../../k8s-helm/.env; set +a

./testQuickstart.sh `realpath ../../k8s-helm/scenarios/DetectLargeTransactionsLite.json`
