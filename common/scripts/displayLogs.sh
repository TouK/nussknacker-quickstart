#!/bin/bash

set -e

cd "$(dirname $0)"
CONTAINER=$1

if [ ! -z "$RELEASE" ]
then
    echo "Logs for $CONTAINER in K8s"
    case $CONTAINER in 
    designer) 
        kubectl logs deploy/$RELEASE-nussknacker
        ;;
    akhq) 
        kubectl logs deploy/$RELEASE-akhq
        ;;
    runtime) 
        kubectl logs -l nussknacker.io/scenarioId
        ;; 
    *)
        echo "Don't know how to display logs of $CONTAINER"   
        ;; 
    esac    
else
    echo "Logs for $CONTAINER in docker"
    case $CONTAINER in 
    runtime) 
        docker logs nussknacker_jobmanager
        ;;
    *)
        docker logs nussknacker_$CONTAINER
        ;;
    esac    
fi