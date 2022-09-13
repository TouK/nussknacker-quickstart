#!/bin/bash

set -e
cd "$(dirname $0)"
set -a; . ../.env; set +a

helm uninstall ${RELEASE}-akhq
kubectl delete pod,service -l nu-quickstart=sample