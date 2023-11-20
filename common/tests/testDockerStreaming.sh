#!/bin/bash -ex

cd "$(dirname "$0")"

source ../scripts/utils.sh

# todo: to remove
  docker ps

./testStreaming.sh "$(fullPath ../../docker/streaming/scenarios/DetectLargeTransactions.json)"

../../docker/streaming/waitForDockerHealthchecks.sh