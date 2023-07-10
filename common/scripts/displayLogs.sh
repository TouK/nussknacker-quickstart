#!/bin/bash

set -e
set -x

cd "$(dirname $0)"
CONTAINER=$1

if [ -z "$RELEASE" ]
then
    echo "********************* Logs for $CONTAINER in docker **************************"
    case $CONTAINER in 
    runtime)
        docker logs `docker ps -q -f name=jobmanager`  # if used in swarm, container names have some random stuff appended
        echo "\n\n\n"
        docker logs `docker ps -q -f name=taskmanager`  # if used in swarm, container names have some random stuff appended
        ;;
    *)
        docker logs `docker ps -q -f name=designer`
        ;;
    esac    
else
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
fi