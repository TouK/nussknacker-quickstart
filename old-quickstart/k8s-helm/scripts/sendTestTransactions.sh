#!/bin/bash -e

cd "$(dirname "$0")"
set -a; . ../.env; set +a

../../common/scripts/sendTestTransactions.sh $@