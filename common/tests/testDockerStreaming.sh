#!/bin/bash -e

cd "$(dirname "$0")"

displayLogs() {
    export BASE_PATH=$(pwd)
    ../../docker/common/displayAllDockerLogs.sh 
}

trap displayLogs ERR

source ../scripts/utils.sh

../scripts/waitForOkFromUrl.sh "api/app/healthCheck" "Checking Nussknacker Health Check API response.." "Nussknacker not started" "designer"

./testStreaming.sh "$(fullPath ../../docker/streaming/scenarios/DetectLargeTransactions.json)"

../../docker/streaming/waitForDockerHealthchecks.sh