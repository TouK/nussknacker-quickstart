#!/bin/bash -e

cd "$(dirname "$0")"
set -a; source ../../k8s-helm/.env; set +a

displayLogs() {
    ../../k8s-helm/scripts/displayAllPodLogs.sh
}

trap displayLogs ERR

source ../scripts/utils.sh

../scripts/waitForOkFromUrl.sh "api/app/healthCheck" "Checking Nussknacker Health Check API response.." "Nussknacker not started" "designer"

./testStreaming.sh "$(fullPath "../../k8s-helm/scenarios/DetectLargeTransactionsLite.json")"
