#!/usr/bin/env sh

set -o errexit
set -o xtrace

find "./.github" -type f \( -name "*.yml" -o -name "*.yaml" \) -exec yq --inplace "{}" \;
