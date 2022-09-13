#!/bin/bash

set -e
cd "$(dirname $0)"
set -a; . ../.env; set +a

kubectl delete pod,service -l nu-quickstart=sample
