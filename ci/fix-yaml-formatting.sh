#!/usr/bin/env sh

set -o errexit
set -o xtrace

# Format all YAML files in the repository.
find "." -type f -name "*.yml" -o -name "*.yaml" | xargs -I {} yq --inplace "{}"
