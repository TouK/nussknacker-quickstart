#!/bin/bash -e

rm -fr /app/healthy

while IFS= read -r script; do
  "$script"
done < <(find /app/scripts/auto-executed -type f -name '*.sh' | sort)

echo "Setup done!"

touch /app/healthy

# loop forever (you can use manually called utils scripts now)
tail -f /dev/null
