#!/bin/bash -e

cd "$(dirname "$0")"

echo "Displaying logs from all started docker containers ..."
echo "--------------------------------------------------------------------"

./invokeDocker.sh logs

echo "--------------------------------------------------------------------"
echo "End of docker logs"
