#!/bin/sh

if [ -z "${RELEASE}" ]; then
  CONTAINER_NAME=$(docker ps | grep nussknacker_kafka | awk '{print $1}')
  echo "inside runInKafka -> first branch"
  echo "$CONTAINER_NAME"
  docker ps
  docker exec -i $CONTAINER_NAME "$@"
else
  #In Docker-based setup we use Confluent image. In K8s setup we use Bitnami. The former has scripts without .sh suffix, while the latter - with it...
  ORIGINAL_COMMAND=$1
  echo $ORIGINAL_COMMAND
  if [ "$ORIGINAL_COMMAND" = "bash" ]; then
    echo "debug 1"
    BITNAMI_COMMAND=$ORIGINAL_COMMAND
  else
    echo "debug 2"
    BITNAMI_COMMAND="$ORIGINAL_COMMAND.sh"
  fi
  echo $BITNAMI_COMMAND
  echo $@
  shift 1
  kubectl exec -i $RELEASE-kafka-0 -- $BITNAMI_COMMAND "$@"
fi