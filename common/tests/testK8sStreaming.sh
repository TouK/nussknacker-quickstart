#!/bin/bash -ex

cd "$(dirname "$0")"
set -a; source ../../k8s-helm/.env; set +a

source ../scripts/utils.sh

curl -v -u admin:admin http://localhost:8081/api/app/healthCheck"

../scripts/waitForOkFromUrl.sh "api/app/healthCheck" "Checking Nussknacker Health Check API response.." "Nussknacker not started" "designer"

./testStreaming.sh "$(fullPath "../../k8s-helm/scenarios/DetectLargeTransactionsLite.json")"
