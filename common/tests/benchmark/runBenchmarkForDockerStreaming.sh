#!/bin/bash -e

cd "$(dirname "$0")"

displayLogs() {
    export BASE_PATH="../../docker/streaming/"
    ../../../docker/common/displayAllDockerLogs.sh 
}

trap displayLogs ERR

./runBenchmark.sh $@ 