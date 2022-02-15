#!/bin/bash

set -e
cd "$(dirname $0)"
../scripts/setEnv.sh

helm uninstall ${RELEASE}-akhq
kubectl delete pod,service -l nu-quickstart=sample