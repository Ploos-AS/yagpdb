#!/bin/sh
set -eu

version=$(cat VERSION)
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

for file in Dockerfile README.md LICENSE NOTICE VERSION compose.yaml .env.example quadlet/yagpdb.container "docs/releases/v${version}.md"; do
  test -s "$file"
done

grep -Fq 'ARG YAGPDB_VERSION=v2.83.1' Dockerfile
grep -Fq 'ARG YAGPDB_COMMIT=7d2a3ba8975a4d0b30c814ada06ca43a969d7348' Dockerfile
grep -Fq 'USER 1000:1000' Dockerfile
grep -Fq 'ghcr.io/ploos-as/yagpdb:0.1.0' compose.yaml
grep -Fq 'valkey/valkey:8-alpine' compose.yaml
grep -Fq 'postgres:17-alpine' compose.yaml
grep -Fq 'ghcr.io/ploos-as/yagpdb:0.1.0' quadlet/yagpdb.container
grep -Fq 'provenance: mode=max' .github/workflows/container.yml
grep -Fq 'sbom: true' .github/workflows/container.yml
grep -Fq 'linux/amd64,linux/arm64' .github/workflows/container.yml

cp .env.example .env
trap 'rm -f .env' EXIT
docker compose config --quiet

echo 'static validation: PASS'
