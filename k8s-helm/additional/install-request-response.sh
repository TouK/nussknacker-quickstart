#!/bin/bash

set -e
cd "$(dirname $0)"
set -a; . ../.env; set +a

./waitForServiceAccount.sh

kubectl apply -f custom-services.yaml
