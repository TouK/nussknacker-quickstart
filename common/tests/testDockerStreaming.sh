#!/bin/bash -e

cd "$(dirname "$0")"

source ../scripts/utils.sh

./testStreaming.sh "$(fullPath ../../docker/streaming/scenarios/DetectLargeTransactions.json)"

../../docker/streaming/waitForDockerHealthchecks.sh