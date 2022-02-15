#!/bin/bash
set -e
cd "$(dirname $0)"
source ../.env
export AKHQ_SECURITY_GROUP=admin

kubectl apply -f custom-services.yaml

helm repo add akhq https://akhq.io/
if [[ -z $DOMAIN ]]
then
export AKHQ_HOST=localhost
else 
export AKHQ_HOST="$RELEASE-nussknacker.$DOMAIN"
fi
envsubst < akhq.yaml | helm upgrade -i $RELEASE-akhq akhq/akhq --debug --values -