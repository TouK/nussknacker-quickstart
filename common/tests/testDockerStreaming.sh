#!/bin/bash -ex

cd "$(dirname "$0")"

source ../scripts/utils.sh

./testStreaming.sh "$(fullPath ../../docker/streaming/scenarios/DetectLargeTransactions.json)"

# todo: to remove
  docker ps

../../docker/streaming/waitForDockerHealthchecks.sh