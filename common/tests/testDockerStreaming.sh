#!/bin/bash

set -e
cd "$(dirname "$0")"

./testStreaming.sh "$(realpath ../../docker/streaming/scenarios/DetectLargeTransactions.json)"

../../docker/streaming/waitForDockerHealthchecks.sh