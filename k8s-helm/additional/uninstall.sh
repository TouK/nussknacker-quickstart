#!/bin/bash

set -e
cd "$(dirname $0)"
source ../.env

helm uninstall ${RELEASE}-akhq
kubectl delete pod,service -l nu-quickstart=sample