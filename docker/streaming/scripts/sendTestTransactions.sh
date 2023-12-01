#!/bin/bash -ex

unset RELEASE || true

cd "$(dirname "$0")"
../../../common/scripts/sendTestTransactions.sh $@