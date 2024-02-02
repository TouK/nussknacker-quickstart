#!/bin/bash -e

if ! command -v "helm" &> /dev/null; then
    echo "heml does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 2
fi

cd "$(dirname "$0")"
source .env

helm repo add --force-update touk https://helm-charts.touk.pl/public
helm repo add --force-update touk-snapshots https://helm-charts.touk.pl/nexus/repository/helm-snapshots/
helm repo update

if [[ "$DEVEL" = true ]]; then
  HELM_REPO=${HELM_REPO:-touk-snapshots/nussknacker}
  DEVEL_ARG="--devel"
else
  HELM_REPO=${HELM_REPO:-touk/nussknacker}
  DEVEL_ARG=""
fi

kubectl get secret "$RELEASE-postgresql" || cat postgres-secret.yaml | POSTGRES_PASSWORD=$(source ../common/scripts/utils.sh && date +%s | sha256 | base64 | head -c 32) RELEASE=$RELEASE MAYBE_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}') NAMESPACE=${MAYBE_NAMESPACE:-default} envsubst | kubectl apply -f -

if [[ -z $DOMAIN ]]
then
  INGRESS_VALS="--set ingress.skipHost=true"
else 
  INGRESS_VALS="--set ingress.skipHost=false --set ingress.domain=$DOMAIN"
fi

IMAGE_VERSION_VALS=""
if [[ -z $NUSSKNACKER_VERSION ]]
then
  IMAGE_VERSION_VALS="--set image.tag=$NUSSKNACKER_VERSION"
fi

COMMAND=${COMMAND:-"upgrade -i"}

CHART_VERSION=${CHART_VERSION:-1.12.4}

helm $COMMAND $DEVEL_ARG "${RELEASE}" $HELM_REPO \
  --wait \
  --timeout=10m \
  --version "$CHART_VERSION" \
  $INGRESS_VALS \
  $IMAGE_VERSION_VALS \
  --set nussknacker.usageStatisticsReportsFingerprint="${USAGE_REPORTS_FINGERPRINT}" \
  --set postgresql.auth.existingSecret="${RELEASE}-postgresql" \
  --set kafka.schemaRegistryCacheConfig.availableSchemasExpirationTime="${NUSSKNACKER_SCHEMAS_CACHE_TTL:-0s}" $@
