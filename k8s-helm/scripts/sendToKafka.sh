#!/bin/bash
set -e

cd "$(dirname $0)"
source ../.env

../../common/scripts/sendToKafka.sh $@