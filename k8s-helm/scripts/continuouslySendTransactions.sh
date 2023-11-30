#!/bin/bash -ex

cd "$(dirname "$0")"
set -a; . ../.env; set +a

../../common/scripts/continuouslySendTransactions.sh $@