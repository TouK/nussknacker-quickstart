#!/bin/sh

if [ -z "${RELEASE}" ]; then
  CONTAINER_NAME=$(docker ps | grep nussknacker_kafka | awk '{print $1}')
  echo "inside runInKafka -> first branch"
  docker exec -i $CONTAINER_NAME "$@"
else
  #In Docker-based setup we use Confluent image. In K8s setup we use Bitnami. The former has scripts without .sh suffix, while the latter - with it...
  ORIGINAL_COMMAND=$1
  BITNAMI_COMMAND="$ORIGINAL_COMMAND.sh"
  shift 1
  kubectl exec -i $RELEASE-kafka-0 -- $BITNAMI_COMMAND "$@"
fi