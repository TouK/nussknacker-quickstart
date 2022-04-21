#!/bin/bash

set -e
cd "$(dirname $0)"
source .env

helm repo add --force-update touk https://helm-charts.touk.pl/public
helm repo add --force-update touk-snapshots https://helm-charts.touk.pl/nexus/repository/helm-snapshots/
helm repo update

HELM_REPO=${HELM_REPO:-touk/nussknacker}

kubectl get secret "$RELEASE-postgresql" || kubectl create secret generic "$RELEASE-postgresql" --from-literal postgresql-password=`date +%s | sha256sum | base64 | head -c 32`

if [[ -z $DOMAIN ]]
then
  ADDITIONAL_VALS="--set ingress.skipHost=true"
else 
  ADDITIONAL_VALS="--set ingress.skipHost=false --set ingress.domain=$DOMAIN"
fi

COMMAND=${COMMAND:-"upgrade -i"}

helm $COMMAND "${RELEASE}" $HELM_REPO \
  --wait \
  $ADDITIONAL_VALS \
  --set postgresql.existingSecret="${RELEASE}-postgresql" \
  -f values.yaml $@ 
