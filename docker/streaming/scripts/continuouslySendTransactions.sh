#!/bin/bash
unset RELEASE
set -e

cd "$(dirname $0)"
../../../common/scripts/continuouslySendTransactions.sh $@