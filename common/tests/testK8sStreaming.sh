#!/bin/bash -ex

cd "$(dirname "$0")"
set -a; source ../../k8s-helm/.env; set +a

sleep 60

source ../scripts/utils.sh

./testStreaming.sh "$(fullPath "../../k8s-helm/scenarios/DetectLargeTransactionsLite.json")"
