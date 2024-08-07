#!/bin/bash -e

cd "$(dirname "$0")"

rm -rf /app/healthy

/app/setup/run-setup.sh
/app/data/keep-sending.sh

echo "Setup done!"

touch /app/healthy

# loop forever (you can use manually called utils scripts now)
tail -f /dev/null