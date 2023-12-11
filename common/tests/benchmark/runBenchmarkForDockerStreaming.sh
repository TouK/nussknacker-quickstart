#!/bin/bash -e

cd "$(dirname "$0")"

displayLogs() {
    ../../../docker/streaming/displayAllStreamingDockerLogs.sh 
}

trap displayLogs ERR

./runBenchmark.sh $@ 