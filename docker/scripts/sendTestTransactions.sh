#!/bin/bash
unset RELEASE
set -e

cd "$(dirname $0)"
../../common/scripts/sendTestTransactions.sh $@