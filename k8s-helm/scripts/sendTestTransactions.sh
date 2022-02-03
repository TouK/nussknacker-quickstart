#!/bin/bash
set -e

cd "$(dirname $0)"
source ../.env

../../common/scripts/sendTestTransactions.sh $@