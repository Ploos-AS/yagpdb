#!/bin/sh
set -eu

image=${IMAGE:-yagpdb:test}

docker run --rm --entrypoint sh "$image" -c 'test "$(id -u)" = 1000 && test "$(id -g)" = 1000'
docker run --rm --entrypoint yagpdb "$image" -help >/tmp/yagpdb-help.txt 2>&1 || true
grep -qi 'usage\|help\|yagpdb' /tmp/yagpdb-help.txt

echo 'smoke validation: PASS'
