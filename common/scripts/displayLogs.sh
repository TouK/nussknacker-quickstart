#!/bin/bash -e

cd "$(dirname "$0")"
CONTAINER=$1

if [ -z "$RELEASE" ]
then
    if ! command -v "docker" &> /dev/null; then
        echo "docker does not exist. Please install it first https://docs.docker.com/engine/install/"
        exit 1
    fi
    echo "********************* Logs for $CONTAINER in docker **************************"
    case $CONTAINER in 
    runtime)
        docker logs "$(docker ps -qa -f name=jobmanager)"  # if used in swarm, container names have some random stuff appended
        echo "\n\n\n"
        docker logs "$(docker ps -qa -f name=taskmanager)"  # if used in swarm, container names have some random stuff appended
        ;;
    *)
        docker logs "$(docker ps -qa -f name=designer)"
        ;;
    esac    
else
    if ! command -v "kubectl" &> /dev/null; then
        echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    echo "Logs for $CONTAINER in K8s"
    case $CONTAINER in 
    designer) 
        kubectl logs "deploy/$RELEASE-nussknacker"
        ;;
    akhq) 
        kubectl logs "deploy/$RELEASE-akhq"
        ;;
    runtime) 
        kubectl logs -l nussknacker.io/scenarioId
        ;; 
    *)
        echo "Don't know how to display logs of $CONTAINER"   
        ;; 
    esac    
fi